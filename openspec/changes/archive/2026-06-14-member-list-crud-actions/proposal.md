## Why

目前 `Admin::UsersController` 僅提供 `index` 與 `export`，管理員只能瀏覽與匯出會員資料，無法在後台建立、修改或刪除會員。所有會員資料目前只能透過 Devise 自助註冊流程（`admin/users/registrations`）產生，管理員缺乏直接管理會員名冊的能力。本變更為會員列表頁補上完整的建立、編輯、刪除操作。

## What Changes

- 在會員列表頁（`app/views/admin/users/index.html.erb`）頁首新增「新增會員」按鈕，連結至新增會員表單。
- 在會員列表每一列新增「檢視」、「編輯」與「刪除」操作按鈕。
- `Admin::UsersController` 新增 `new`、`create`、`show`、`edit`、`update`、`destroy` 動作。
- 新增會員時，系統自動產生一組隨機密碼（管理員不需輸入密碼），以滿足 Devise `database_authenticatable` 的密碼需求；表單僅收集會員基本資料（`id_number`、`name`、`phone_number`、`birth_date`、`address`、`email`、`zodiac`、`status`）。
- 編輯會員時可修改上述基本資料；不在編輯表單中變更密碼。
- 檢視會員時顯示該會員完整基本資料（`id_number`、`name`、`phone_number`、`birth_date`、`sex`、`address`、`email`、`zodiac`、`status`），為唯讀詳情頁。
- 刪除會員需經前端確認對話框，且**禁止刪除目前登入中的管理員自己的帳號**。
- 路由 `resources :users` 由 `only: [:index]` 擴充為包含 `new`、`create`、`show`、`edit`、`update`、`destroy`（保留既有 `export` collection route）。
- 停用 Devise 自助註冊：`User` 移除 `:registerable`、`devise_for :users` 移除 registrations 對應，以釋出與會員 `create` 衝突的 `POST /admin/users` 路由（原本被 Devise 註冊搶先佔用）。同時移除自助註冊的 controller、views 與對應 feature spec。
- 新增共用表單 partial 與 new／edit 視圖、唯讀 show 視圖，並補上對應的 i18n 文案（`zh-TW`）。

## Non-Goals

- 不提供會員密碼的後台重設介面；自動產生的隨機密碼於本變更不對外顯示或寄送（會員若需登入仍可走既有「忘記密碼」流程）。
- 不新增權限分級（role-based authorization）；任何已登入管理員皆可執行 CRUD，唯一限制為禁止刪除自己。
- 不變更會員列表的搜尋、排序、分頁與 Excel 匯出行為。
- 會員詳情頁僅為唯讀顯示，不在 show 頁提供編輯或刪除的內嵌操作（由列表頁按鈕負責）。

## Capabilities

### New Capabilities

- `member-management`: 後台會員名冊的建立、檢視、編輯與刪除（CRUD）操作，包含自動產生密碼與禁止自我刪除的安全規則。

### Modified Capabilities

(none)

## Impact

- Affected specs: `member-management`（新增）
- Affected code:
  - New:
    - `app/views/admin/users/new.html.erb`
    - `app/views/admin/users/edit.html.erb`
    - `app/views/admin/users/show.html.erb`
    - `app/views/admin/users/_form.html.erb`
  - Modified:
    - `config/routes.rb`
    - `app/controllers/admin/users_controller.rb`
    - `app/models/user.rb`
    - `app/views/admin/users/index.html.erb`
    - `config/locales/zh-TW.yml`
  - Removed:
    - `app/controllers/admin/users/registrations_controller.rb`
    - `app/views/admin/users/registrations/new.html.erb`
    - `app/views/admin/users/registrations/edit.html.erb`
    - `spec/features/admin/user_sign_up_spec.rb`
