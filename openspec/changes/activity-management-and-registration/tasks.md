## 1. 資料模型：ActivityRegistration 整合報名、繳費、取消資訊於同一張表

- [x] 1.1 建立 `create_activities` migration：欄位含 title (string, not null)、description (text, not null)、notes (text)、event_date (date, not null)、registration_start_date (date, not null)、registration_end_date (date, not null)、fee (decimal precision:10 scale:2, not null)、status (integer, not null, default: 0)
- [x] 1.2 建立 `create_activity_registrations` migration：欄位含 activity_id (bigint, not null, FK)、user_id (bigint, not null, FK)、status (integer, not null, default: 0)、payment_method (integer)、collector (string)、paid_at (datetime)、cancel_reason (string)、cancelled_at (datetime)、refund_amount (decimal precision:10 scale:2)、refunded_at (datetime)；加入 unique index on [activity_id, user_id]
- [x] [P] 1.3 建立 `app/models/activity.rb`：`enum :status, { draft: 0, published: 1 }`；`has_many_attached :photos`；`has_many :activity_registrations, dependent: :destroy`；`has_many :registered_users, through: :activity_registrations, source: :user`；validates presence of title, description, event_date, registration_start_date, registration_end_date, fee；validate registration_end_date >= registration_start_date；加入 `ransackable_attributes` 含 title、event_date、status
- [x] [P] 1.4 建立 `app/models/activity_registration.rb`：`enum :status, { pending: 0, paid: 1, cancelled: 2 }`；`enum :payment_method, { transfer: 0, cash: 1 }, validate: { allow_nil: true }`；`belongs_to :activity`；`belongs_to :user`；加入 scope `active` (status pending or paid)；加入 scope `cancellable` (status pending or paid)

## 2. 路由設計：registrations 作為 activities 的 nested resource

- [x] 2.1 路由設計：registrations 作為 activities 的 nested resource，payment 以 collection action 處理 — 在 `config/routes.rb` 的 `admin` namespace 下新增：`resources :activities`；nested `resources :registrations, only: [:index, :create], controller: 'activities/registrations'` 含 collection actions `post :pay` 與 `post :cancel`

## 3. Activity 管理：Create Activity 與 Edit Activity

- [x] 3.1 搜尋：Ransack + 民國年份轉換於 Controller 層 — 建立 `app/controllers/admin/activities_controller.rb`：實作 index、show、new、create、edit、update actions；index action 套用 Ransack (`@q = Activity.ransack(params[:q])`)、支援 Activity List Search by ROC Year（將 params[:roc_year] 轉為西元年 +1911 後用 `event_date_year_eq` 過濾）、以 `event_date DESC` 排序
- [x] [P] 3.2 建立 `app/views/admin/activities/index.html.erb`：表格顯示 Activity List 欄位（title、event_date、報名起迄、published 狀態、fee）；每列含 Activity List Row Actions 三個按鈕（編輯、檢視、報名與繳費）；頂部含搜尋表單（title 模糊搜尋輸入框、民國年份輸入框）
- [x] [P] 3.3 建立 `app/views/admin/activities/new.html.erb` 與 `_form.html.erb`：含所有 Create Activity 必填欄位的表單（title、description、notes、event_date、registration_start_date、registration_end_date、fee、status 下拉選單、photos 多檔上傳）；顯示 validation errors
- [x] [P] 3.4 建立 `app/views/admin/activities/edit.html.erb`：重用 `_form` partial；顯示已附加的照片並提供刪除個別照片的按鈕（使用 Active Storage `purge` endpoint）
- [x] [P] 3.5 建立 `app/views/admin/activities/show.html.erb`：唯讀顯示所有欄位與 View Activity Detail 所有照片

## 4. 報名管理：View Registration List 與 Register Users via Modal

- [x] 4.1 建立 `app/controllers/admin/activities/registrations_controller.rb`：index action 載入 `@activity` 與其所有 `activity_registrations.includes(:user)`；create action 接收 user_ids 陣列，略過已 active 報名者，批次建立 `ActivityRegistration` (status: :pending)，回傳 Turbo Stream 更新列表
- [x] [P] 4.2 建立 `app/views/admin/activities/registrations/index.html.erb`：View Registration List 的表格（checkbox、name、status、id_number、sex、zodiac、birth_date、phone_number、報名狀態）；頂部三個操作按鈕（報名、繳費、取消報名）；引入三個 Turbo Frame modal containers
- [x] [P] 4.3 建立報名 modal 的 Turbo Frame 視圖 `app/views/admin/activities/registrations/_register_modal.html.erb`：包含 User 搜尋輸入框（Turbo Frame 即時搜尋）、搜尋結果 checkbox 列表、確定按鈕；搜尋結果 frame id 為 `user_search_results`
- [x] [P] 4.4 建立 `app/views/admin/activities/registrations/_user_search_results.html.erb`：供 Register Users via Modal 搜尋的 Turbo Frame partial，根據 name 或 id_number 模糊查詢 User，顯示 checkbox 列表（排除已 active 報名者）

## 5. 取消報名：Cancel Registration via Modal

- [x] 5.1 在 `registrations_controller.rb` 實作 `cancel` collection action：接收 registration_ids 陣列；過濾出 `cancellable` 狀態的紀錄；批次更新 status: :cancelled、cancel_reason、cancelled_at；對 paid 狀態者額外記錄 refund_amount 與 refunded_at（僅當 params[:refund_amount] 非空）；回傳 Turbo Stream 更新列表
- [x] [P] 5.2 建立取消 modal 的 Turbo Frame 視圖 `app/views/admin/activities/registrations/_cancel_modal.html.erb`：實作 Cancel Registration via Modal 邏輯：必填 cancel_reason 文字欄位；條件性顯示退費金額欄位（當選取中含 paid 者）；取消 modal 的退費欄位顯示邏輯警告訊息（黃色 banner，當同時含 paid 與 pending 者）

## 6. 繳費：Mark Registrations as Paid via Modal

- [x] 6.1 建立 `app/controllers/admin/activities/payments_controller.rb`（對應路由 `post :pay` on registrations collection）：接收 registration_ids 陣列；過濾出 status: :pending 的紀錄；批次更新 status: :paid、payment_method、collector、paid_at；已 paid 或 cancelled 者略過；回傳 Turbo Stream 更新列表
- [x] [P] 6.2 建立繳費 modal 的 Turbo Frame 視圖 `app/views/admin/activities/registrations/_pay_modal.html.erb`：Mark Registrations as Paid via Modal 的 UI：必填 payment_method 下拉選單（轉帳/現金）、必填 collector 文字欄位、確定按鈕

## 7. Modal 互動：Turbo Frame + Stimulus controller

- [x] 7.1 建立 `app/javascript/controllers/modal_controller.js` Stimulus controller：提供 open/close actions 切換 modal 顯示；支援點擊背景關閉
- [x] 7.2 建立 `app/javascript/controllers/registration_form_controller.js` Stimulus controller：維護 checkbox 選取狀態（收集選取的 registration_ids 與 user_ids）；在開啟繳費/取消 modal 前判斷選取名單中是否含 paid 狀態（傳入 modal 以控制退費欄位顯示）；實作搜尋 input 的 debounce（300ms）觸發 Turbo Frame 更新 `user_search_results`

## 8. 測試

- [x] [P] 8.1 建立 `spec/factories/activities.rb` 與 `spec/factories/activity_registrations.rb`
- [x] [P] 8.2 建立 `spec/models/activity_spec.rb`：測試 validations（必填欄位、registration_end_date >= registration_start_date）、enum 定義、ransackable_attributes
- [x] [P] 8.3 建立 `spec/models/activity_registration_spec.rb`：測試 enum 定義、`active` scope、`cancellable` scope
- [x] [P] 8.4 建立 `spec/requests/admin/activities_spec.rb`：測試 index（含搜尋 Activity List Search by Title 與 Activity List Search by ROC Year）、show（View Activity Detail）、create（Create Activity 成功與失敗）、update（Edit Activity）
- [x] [P] 8.5 建立 `spec/requests/admin/activities/registrations_spec.rb`：測試 index（View Registration List）、create（Register Users via Modal 含已報名者略過）、cancel（Cancel Registration via Modal 含 pending/paid/混選各情境）
- [x] [P] 8.6 建立 `spec/requests/admin/activities/payments_spec.rb`：測試 pay（Mark Registrations as Paid via Modal 含各狀態略過邏輯）
