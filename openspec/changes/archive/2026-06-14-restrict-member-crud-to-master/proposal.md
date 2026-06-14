## Why

目前 `Admin::UsersController` 只用 `authenticate_user!` 確認登入，任何登入者都能新增、編輯、刪除會員資料。會員管理屬於高敏感操作，應只開放給宮主（`status: master`）身分的使用者，避免一般幹部或會員誤改或刪除他人資料。

## What Changes

- 導入 `pundit` gem 作為授權框架（`ApplicationController` 加入 `include Pundit::Authorization`）。
- 新增 `UserPolicy`，定義會員資料的授權規則：只有 `status` 為 `master` 的登入者可執行 `create`、`new`、`edit`、`update`、`destroy`；`index`、`show`、`export` 維持所有登入者皆可存取。
- `Admin::UsersController` 在寫入動作（`new`/`create`/`edit`/`update`/`destroy`）加入 `authorize` 呼叫，授權失敗時導回會員列表並顯示權限不足的 flash 訊息。
- 在會員列表與詳情頁的「新增會員」「編輯」「刪除」按鈕加上 policy 判斷，非宮主使用者不顯示這些按鈕。
- 新增 i18n 文案（權限不足提示訊息）。

## Non-Goals (optional)

- 不調整 `status` enum 的定義或既有 `master` 以外身分的權限細分（本次僅區分「宮主可寫入」與「其他僅可讀」）。
- 不為其他 controller（如 activities、dashboard）加入授權，僅限會員管理。
- 不引入角色（role）資料表或更複雜的 RBAC 機制，授權判斷直接以既有 `status` enum 為依據。
- 不更動 Devise 登入流程與既有認證機制。

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `member-management`: 在既有的會員 CRUD 行為上加入授權要求——寫入類動作（新增/編輯/刪除）限定 `status: master` 的登入者，讀取類動作不變；對應 UI 按鈕依授權結果顯示或隱藏。

## Impact

- 相依套件：新增 `pundit` gem。
- Affected specs：`member-management`（modified）。
- Affected code：
  - New:
    - `app/policies/application_policy.rb`
    - `app/policies/user_policy.rb`
    - `spec/policies/user_policy_spec.rb`
  - Modified:
    - `Gemfile`
    - `app/controllers/application_controller.rb`
    - `app/controllers/admin/users_controller.rb`
    - `app/views/admin/users/index.html.erb`
    - `app/views/admin/users/show.html.erb`
    - `config/locales`（權限不足 flash 文案）
    - `spec/requests`（會員管理授權的 request spec）
  - Removed: (none)
