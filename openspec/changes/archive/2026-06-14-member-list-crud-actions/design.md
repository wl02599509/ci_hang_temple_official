## Context

會員資料以 `User` model 儲存，採用 Devise（`database_authenticatable`、`registerable`、`validatable`），登入鍵為 `id_number`。目前 `config/routes.rb` 中 `resources :users, only: [:index]`，`Admin::UsersController` 只有 `index` 與 `export`，會員列表頁（`app/views/admin/users/index.html.erb`）僅能瀏覽與匯出。既有的 `Admin::Activities` 資源已實作完整 CRUD（含 `_form` partial、`new`／`edit` 視圖、確認刪除），可作為本變更的實作範本。

`User` 因 `:validatable` 在建立時要求密碼存在（`password_required?` 為真），這是本設計需要處理的主要約束。

## Goals / Non-Goals

**Goals:**

- 在會員列表頁提供「新增會員」「編輯」「刪除」三項操作。
- `Admin::UsersController` 補上 `new`、`create`、`edit`、`update`、`destroy`。
- 新增會員時自動產生隨機密碼，管理員不需輸入密碼。
- 刪除時禁止刪除目前登入中的管理員自己的帳號。
- 沿用 Activities 既有的 UI 與表單樣式（`btn`、`form-group`、`data-table` 等 class）。

**Non-Goals:**

- 不更動 Devise 自助註冊流程（`admin/users/registrations`）。
- 不提供密碼重設介面、不顯示或寄送自動產生的密碼。
- 不加入角色權限分級（唯一限制為禁止刪除自己）。
- 不變更搜尋、排序、分頁、Excel 匯出。
- show 頁僅唯讀，不在頁內提供編輯／刪除等內嵌操作。

## Decisions

### 停用 Devise 自助註冊以釋出 POST /admin/users

實作時發現 `devise_for :users, path: "admin/users"` 因 `:registerable` 產生 `POST /admin/users → registrations#create`，且宣告在 `resources :users` 之前，搶先佔用會員 `create` 用的 `POST /admin/users`；已登入管理員送出時被 Devise `require_no_authentication` 導向 root `/` 且不建立任何紀錄。依使用者決策停用自助註冊：`User` 移除 `:registerable`、`devise_for :users` 的 `controllers` 移除 `registrations` 對應，使 `POST /admin/users` 由 `Admin::UsersController#create` 接手；並移除 `Admin::Users::RegistrationsController`、其 `new`／`edit` 視圖與 `spec/features/admin/user_sign_up_spec.rb`。`devise/shared/_links` 的 sign_up 連結受 `devise_mapping.registerable?` 守衛，移除模組後自動不顯示。
- 替代方案：會員 CRUD 改掛 `/admin/members`（保留自助註冊）—使用者選擇關閉自助註冊，未採用；將 Devise 註冊改到其他路徑—同樣需改動註冊流程，未採用。

### 自動產生隨機密碼以滿足 Devise 密碼需求

隨機密碼於 **model 層**處理，作為「會員一定有密碼」的網域不變式：`User` 以 `before_validation :assign_default_password, on: :create` 在 `password` 為空時設為 `SecureRandom.base58(24)`，使 `:validatable` 的密碼驗證通過。控制器 `create` 不再碰密碼。表單不含密碼欄位；`set_sex` callback 仍由 `id_number` 推導 `sex`，故 strong params 不含 `sex`、`password`。已提供密碼者（factory、未來流程）不被覆寫。
- 替代方案：在 controller 設定密碼（業務邏輯外漏到控制器，已改為 model 層）；放寬 model 密碼驗證（改動登入模型，風險高，已否決）；要求管理員輸入密碼（多一道無意義的操作，已依使用者選擇否決）。

### 編輯時不變更密碼且避免密碼驗證

`update` 使用不含 `password` 的 strong params；Devise 在 `password` 為空時 `password_required?` 對既有紀錄回傳 false，故更新基本資料不會觸發密碼驗證錯誤。不採用 Devise 的 `update_with_password`（那需要 `current_password`，屬於使用者自助情境，不適用後台管理）。

### 唯讀會員詳情頁

`show` 動作以 `set_user` 取得 `@user`，render 唯讀 `show.html.erb`，顯示 `id_number, name, phone_number, birth_date, sex, address, email, zodiac, status`，不顯示任何密碼或 Devise 憑證欄位，也不在頁內提供編輯／刪除操作（操作由列表頁按鈕負責）。`sex`、`zodiac`、`status` 以 enum 對應的中文 i18n 顯示。

### 刪除前的自我刪除防護

`destroy` 動作在刪除前比對 `@user == current_user`（或 `@user.id == current_user.id`）。若為自己，跳過刪除、`redirect_to admin_users_path` 並帶 `alert` 訊息；否則執行 `destroy` 後 redirect 並帶 `notice`。前端刪除按鈕使用 `button_to ... method: :delete` 搭配 `data: { turbo_confirm: ... }` 觸發確認對話框。

### 路由與 strong params 範圍

`config/routes.rb` 將 `resources :users, only: [:index]` 擴充為 `only: [:index, :new, :create, :show, :edit, :update, :destroy]`，保留既有 `collection { get :export }`。strong params `user_params` 允許 `:id_number, :name, :phone_number, :birth_date, :address, :email, :zodiac, :status`。

### 視圖與 i18n

新增 `app/views/admin/users/_form.html.erb`（共用於 new／edit）、`new.html.erb`、`edit.html.erb`，以及唯讀 `show.html.erb`，沿用 Activities 的表單與版面樣式。`index.html.erb` 頁首加「新增會員」按鈕、每列加「檢視」「編輯」「刪除」操作欄。flash 訊息（成功、禁止自我刪除）文案寫入 `config/locales/zh-TW.yml`。

## Implementation Contract

- **Behavior**：
  - 列表頁頁首出現「新增會員」按鈕；每列出現「檢視」「編輯」「刪除」按鈕。
  - 點「新增會員」→ 進入 new 表單；填妥合法資料送出 → 建立會員（含自動隨機密碼）並導回列表。
  - 點某列「檢視」→ 進入該會員唯讀詳情頁，顯示完整基本資料，不顯示密碼欄。
  - 點某列「編輯」→ 進入該會員 edit 表單；送出合法修改 → 更新並導回列表。
  - 點某列「刪除」→ 前端確認對話框；確認後刪除並導回列表，但若目標為自己則不刪除並顯示錯誤 flash。
- **Interface**：
  - 路由：`new_admin_user_path`、`POST admin_users_path`、`admin_user_path(user)`（GET show）、`edit_admin_user_path(user)`、`PATCH/PUT admin_user_path(user)`、`DELETE admin_user_path(user)`。
  - 控制器動作：`Admin::UsersController#new/create/show/edit/update/destroy`，`set_user` before_action 套用於 `show/edit/update/destroy`。
  - strong params：`user_params` 允許 `id_number, name, phone_number, birth_date, address, email, zodiac, status`。
- **Failure modes**：
  - `create`／`update` 驗證失敗 → `render :new`／`:edit`，`status: :unprocessable_entity`，顯示 `user.errors`。
  - `destroy` 目標為 `current_user` → 不刪除、redirect 回列表、`flash[:alert]` 顯示禁止自我刪除訊息。
- **Acceptance criteria**：
  - request spec 驗證六個動作的成功與失敗路徑，以及自我刪除被擋（記錄數不變、出現錯誤訊息）。
  - `show` 頁回應 200 且含會員 `name`／`id_number` 等欄位、不含密碼欄位。
  - 自動產生密碼：建立後 `user.valid_password?` 對未知密碼回傳 false，且 `encrypted_password` 非空。
  - `bin/rubocop` 通過。
- **In scope**：路由、控制器六動作、`_form`／`new`／`edit`／`show` 視圖、`index` 操作按鈕、`zh-TW` flash 文案、對應 specs 的測試。
- **Out of scope**：密碼重設／顯示、權限分級、搜尋／排序／分頁／匯出之變更、Devise 註冊流程；show 頁僅唯讀、不含內嵌編輯／刪除操作。

## Risks / Trade-offs

- [自動隨機密碼導致會員無法自行登入] → 會員若需登入可走既有「忘記密碼」（`recoverable`）流程重設；本變更定位為後台名冊管理，符合使用者選擇。
- [刪除為硬刪除，無法復原] → 以前端 `turbo_confirm` 確認對話框降低誤刪；自我刪除另有後端防護。軟刪除不在本次範圍。
- [strong params 未含 `sex`，依賴 `set_sex` callback] → 由 `id_number` 自動推導，與既有註冊流程行為一致，無新增風險。
