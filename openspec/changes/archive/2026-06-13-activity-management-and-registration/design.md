## Context

目前系統已有 `User` 模型與 Admin namespace 的後台架構（含 Devise 認證、Ransack 搜尋、Hotwire/Turbo + Stimulus）。本次新增活動管理與報名繳費功能，完全在 Admin namespace 下擴充，不影響現有認證流程。

## Goals / Non-Goals

**Goals:**

- 讓後台人員可建立與管理宮廟活動（含多張照片、費用、報名時間起迄、狀態管理）
- 讓後台人員可替信眾報名活動、記錄繳費、取消報名（含退費）
- 列表頁支援主題名稱模糊搜尋與民國年份搜尋

**Non-Goals:**

- 不提供前台（信眾自行登入）報名功能
- 不實作信眾端線上付款（第三方金流）
- 不限制活動狀態或報名時間：後台人員可無視 draft/published 與報名期限進行報名操作
- 不支援分期繳費或多次退費：每筆報名僅有一次繳費記錄

## Decisions

### 資料模型：ActivityRegistration 整合報名、繳費、取消資訊於同一張表

不另開 `ActivityPayment` 或 `ActivityCancellation` 表，所有狀態欄位集中在 `activity_registrations`：

```
activities
  id, title, description, notes, event_date (date)
  registration_start_date (date), registration_end_date (date)
  fee (decimal, precision: 10, scale: 2)
  status (integer, enum: draft: 0, published: 1, default: 0)
  created_at, updated_at

activity_registrations
  id, activity_id, user_id
  status (integer, enum: pending: 0, paid: 1, cancelled: 2, default: 0)
  payment_method (integer, enum: transfer: 0, cash: 1, nullable)
  collector (string, nullable)
  paid_at (datetime, nullable)
  cancel_reason (string, nullable)
  cancelled_at (datetime, nullable)
  refund_amount (decimal, precision: 10, scale: 2, nullable)
  refunded_at (datetime, nullable)
  created_at, updated_at
```

活動照片使用 Active Storage `has_many_attached :photos`，不在 schema 中新增欄位。

**理由**：一個報名紀錄對應一次繳費、一次取消，無需多對多。集中在同一表減少 JOIN，查詢簡單。

### 路由設計：registrations 作為 activities 的 nested resource，payment 以 collection action 處理

```ruby
namespace :admin do
  resources :activities do
    resources :registrations, only: [:index, :create, :destroy],
              controller: 'activities/registrations' do
      collection do
        post :pay       # 批次繳費
        post :cancel    # 批次取消報名
      end
    end
  end
end
```

**理由**：registrations 的語義上屬於 activity，nested resource 讓 URL 語義清晰（`/admin/activities/:activity_id/registrations`）。繳費與取消以 collection action 處理，支援批次操作。

### Modal 互動：Turbo Frame + Stimulus controller

三個 modal（報名、繳費、取消）使用 Turbo Frame 渲染 modal 內容，Stimulus controller 負責：
1. 開啟/關閉 modal（切換 CSS class）
2. 維護 checkbox 選取狀態（取得選取的 user_id 列表）
3. 報名 modal 的即時 User 搜尋（debounce input → Turbo Frame request）

**理由**：與現有 Hotwire 架構一致，不引入額外 JS 套件。

### 搜尋：Ransack + 民國年份轉換於 Controller 層

Activity model 加入 `ransackable_attributes`，支援 `title_cont`（主題名稱模糊）。民國年份搜尋在 controller 將輸入值 +1911 轉為西元年，再用 `event_date_year_eq` scope 查詢。

**理由**：Ransack 已是現有搜尋方案，維持一致性。民國轉換邏輯簡單，放 controller 避免汙染 model。

### 取消 modal 的退費欄位顯示邏輯

當多選的報名者中含有 `paid` 狀態者，顯示退費金額欄位。若同時含有 `pending` 狀態者，顯示黃色提示：「多選的報名者中有未繳費者，退費金額不會套用於未繳費者」。

退費欄位為選填，留空則不記錄 `refund_amount`，即使對象是 `paid` 狀態。

## Risks / Trade-offs

- **批次操作的狀態不一致**：多選時可能包含已取消的報名者，Controller 需過濾非合法狀態的對象，並回傳處理摘要。→ 在 service object 或 model scope 中做防禦性過濾
- **Active Storage 照片上傳效能**：多張照片同步上傳在低網速環境可能很慢。→ 本次不做非同步上傳優化，接受此限制
- **Ransack 民國年份搜尋**：`event_date_year_eq` 需確認 PostgreSQL 支援 `date_part('year', ...)` 的 Ransack scope，若不支援需改用自訂 scope。→ 實作時先驗證，必要時用 `where("EXTRACT(YEAR FROM event_date) = ?", year)` 替代

## Open Questions

（無）
