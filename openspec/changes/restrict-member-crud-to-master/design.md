## Context

`Admin::UsersController` 目前僅以 `before_action :authenticate_user!` 保護，所有登入者皆可存取全部 CRUD 動作（`index`/`show`/`new`/`create`/`edit`/`update`/`destroy`/`export`）。`User` model 已有 `status` enum，其中 `master: 0`（宮主）代表最高權限身分。系統尚未安裝任何授權框架。需求是限制寫入類操作（新增/編輯/刪除）只開放給 `master` 身分，讀取類操作維持不變。

約束：
- 不引入新的角色資料表；授權判斷直接以既有 `status` enum 為依據。
- 既有測試以 RSpec + FactoryBot 撰寫，新授權邏輯需有對應測試。
- 控制器命名空間為 `Admin`，`Admin::UsersController < Admin::ApplicationController < ActionController::Base`。

## Goals / Non-Goals

**Goals:**
- 以 `pundit` gem 建立可重用的授權層。
- 限制 `new`/`create`/`edit`/`update`/`destroy` 只允許 `current_user.master?`。
- 讀取類動作（`index`/`show`/`export`）維持所有登入者可存取。
- 授權失敗時不丟出未處理例外，而是導回會員列表並顯示權限不足提示。
- 非宮主使用者在 UI 上看不到新增/編輯/刪除按鈕。

**Non-Goals:**
- 不為 activities、dashboard 等其他 controller 加授權。
- 不細分 `master` 以外身分的權限差異。
- 不調整 Devise 認證流程。

## Decisions

### 採用 Pundit 而非 CanCanCan 或自寫 before_action

選擇 `pundit`：policy 物件以純 Ruby class 表達、與 `status` enum 對應清楚、易於單元測試、社群維護活躍。CanCanCan 以集中式 Ability 定義，對單一資源的細緻控制較不直觀；自寫 `before_action` 條件判斷會把授權邏輯散落在 controller、難以測試與重用。Pundit 的 policy + `authorize` 慣例最符合本專案以 enum 表達身分的模型。

### 以 UserPolicy 對應寫入動作，讀取動作一律放行

`UserPolicy` 繼承 `ApplicationPolicy`。`index?`/`show?` 回傳 `true`（任何登入者可讀）；`create?`/`new?`/`update?`/`edit?`/`destroy?` 回傳 `user.master?`。`new?` 預設委派 `create?`、`edit?` 預設委派 `update?`（Pundit 預設行為），因此只需實作 `create?`、`update?`、`destroy?` 與讀取動作即可。`export` 不是標準 Pundit 動作，於 controller 中不呼叫 `authorize`，維持所有登入者可匯出。

### 授權失敗以 rescue_from 轉為使用者友善導向

在 `Admin::ApplicationController`（`< ActionController::Base`，所有 admin 控制器的共同父類，並非繼承自頂層 `ApplicationController`）以 `include Pundit::Authorization` 並 `rescue_from Pundit::NotAuthorizedError` 攔截，導回 `admin_users_path` 並帶 `alert` flash（i18n key `pundit.not_authorized`），避免出現 500 錯誤頁。因 admin 命名空間自成繼承樹，Pundit 的 include 與 rescue 皆須放在 `Admin::ApplicationController`；放在頂層 `ApplicationController` 不會作用於 admin 控制器。

### UI 按鈕以 policy 方法控制顯示

在 `index.html.erb` 與 `show.html.erb` 用 `policy(@user).edit?`、`policy(@user).destroy?`、`policy(User).create?` 包住對應按鈕，非宮主使用者不顯示。此舉與 controller 端授權互補：UI 隱藏避免誤導，controller `authorize` 為真正的存取防線。

## Implementation Contract

**可觀察行為：**
- 以 `master` 身分登入者：可正常開啟 `new`/`edit` 表單、成功 `create`/`update`/`destroy` 會員，且列表/詳情頁顯示新增、編輯、刪除按鈕。
- 以非 `master`（如 `normal`、`member`）身分登入者：
  - 直接 GET/POST 寫入路由（`new_admin_user_path`、`POST admin_users_path`、`edit_admin_user_path`、`PATCH/PUT`、`DELETE`）時，被導回 `admin_users_path`，HTTP 為 redirect（302），並顯示權限不足 flash（i18n `pundit.not_authorized`）。
  - 列表頁與詳情頁不顯示新增/編輯/刪除按鈕。
  - 仍可存取 `index`、`show`、`export`。
- 未登入者：維持既有 `authenticate_user!` 行為，導向登入頁。

**介面/設定：**
- `Gemfile` 新增 `gem "pundit"`。
- `ApplicationController` 加入 `include Pundit::Authorization` 與 `rescue_from Pundit::NotAuthorizedError`。
- `app/policies/application_policy.rb`：標準 Pundit base policy。
- `app/policies/user_policy.rb`：實作 `index?`、`show?`（true）與 `create?`、`update?`、`destroy?`（`user.master?`）。
- `Admin::UsersController`：在 `new`/`create`/`edit`/`update`/`destroy` 呼叫 `authorize @user`（`new`/`create` 用 `authorize User`）。

**驗收準則：**
- `spec/policies/user_policy_spec.rb`：以 `master` user 對寫入動作回傳 true、對非 master user 回傳 false；讀取動作對所有人回傳 true。
- request spec：非 master 登入者對五個寫入動作皆被導回列表並帶 alert；master 登入者可成功操作。

**範圍邊界：**
- In scope：`Admin::UsersController` 的會員 CRUD 授權與對應 UI 按鈕、Pundit 安裝與 base policy、i18n 文案、policy 與 request 測試。
- Out of scope：其他 controller 的授權、`status` enum 變更、角色資料表、Devise 流程調整、`export` 動作的授權限制。

## Risks / Trade-offs

- [既有以 `authenticate_user!` 為唯一防線的測試可能因新增授權而失敗] → 更新或新增 request spec，明確以 `master` 身分登入測試寫入路徑。
- [`export` 不受授權限制，非宮主仍可匯出全部會員資料] → 屬刻意決策（讀取放行）；若日後需限制再另開變更。
- [UI 隱藏按鈕但未擋路由會被繞過] → controller 端 `authorize` 為真正防線，UI 僅為輔助。
- [Pundit 預設 `verify_authorized` callback 若啟用會要求每個 action 都呼叫 authorize] → 本變更不啟用 `after_action :verify_authorized`，避免讀取動作被強制要求 authorize。

## Migration Plan

1. `Gemfile` 新增 pundit 並 `bundle install`。
2. 建立 policies 與 controller 變更、UI 按鈕條件、i18n 文案。
3. 執行 `bundle exec rspec` 確認 policy 與 request 測試通過、既有測試未回歸。
4. 部署。回滾策略：本變更不含資料庫遷移，回滾僅需還原程式碼與移除 gem。

## Open Questions

(none)
