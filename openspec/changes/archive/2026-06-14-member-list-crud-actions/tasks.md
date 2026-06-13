## 1. 路由與控制器

- [x] 1.1 依「路由與 strong params 範圍」決策，將 `config/routes.rb` 中 `resources :users` 擴充為 `only: [:index, :new, :create, :show, :edit, :update, :destroy]` 並保留既有 `collection { get :export }`。驗證：`bin/rails routes -c admin/users` 顯示 new/create/show/edit/update/destroy 六條路由且 export 仍存在。
- [x] 1.2 在 `Admin::UsersController` 實作 "Admin creates a member from the member list"：`new` 建立空 `User`，`create` 套用「自動產生隨機密碼以滿足 Devise 密碼需求」決策（密碼於 model `before_validation :assign_default_password` 自動產生，controller 不碰密碼），成功導回 `admin_users_path`、失敗 `render :new, status: :unprocessable_entity`；新增 `user_params`（`id_number, name, phone_number, birth_date, address, email, zodiac, status`）。驗證：request spec 對合法/重複 id_number 各跑一次，分別斷言記錄數 +1 與 422。
- [x] 1.3 在 `Admin::UsersController` 實作 "Admin edits an existing member"：`set_user` before_action 套用於 `show/edit/update/destroy`，依「編輯時不變更密碼且避免密碼驗證」決策，`update` 使用不含 password 的 `user_params`，成功導回列表、失敗 `render :edit, status: :unprocessable_entity`。驗證：request spec 對既有會員不帶密碼更新基本資料成功（無密碼驗證錯誤），無效資料回 422。
- [x] 1.4 在 `Admin::UsersController#show` 實作 "Admin views a member detail page"，套用「唯讀會員詳情頁」決策：以 `set_user` 取得 `@user` 並 render 唯讀詳情，不含任何密碼欄位。驗證：request spec 對既有會員 GET show 回 200 且 body 含其 `name`／`id_number`、不含密碼欄位。
- [x] 1.5 在 `Admin::UsersController#destroy` 實作 "Admin deletes a member with a self-deletion guard"，套用「刪除前的自我刪除防護」決策：目標為 `current_user` 時不刪除並以 `flash[:alert]` 導回列表，否則 `destroy` 後以 `flash[:notice]` 導回列表。驗證：request spec 斷言刪除他人記錄數 -1、刪除自己記錄數不變且回傳錯誤訊息。
- [x] 1.6 依「停用 Devise 自助註冊以釋出 POST /admin/users」決策，於 `app/models/user.rb` 移除 `:registerable`、於 `config/routes.rb` 的 `devise_for :users` 移除 registrations 對應，並移除 `Admin::Users::RegistrationsController`、其 `new`／`edit` 視圖與 `spec/features/admin/user_sign_up_spec.rb`。驗證：`bin/rails routes` 中 `POST /admin/users` 僅剩 `admin/users#create` 一筆；`bundle exec rspec spec/features/admin/user_sign_in_spec.rb` 仍通過。

## 2. 視圖

- [x] 2.1 [P] 依「視圖與 i18n」決策新增共用表單 `app/views/admin/users/_form.html.erb` 並建立 `new.html.erb`、`edit.html.erb`，沿用 Activities 表單樣式，欄位涵蓋 `id_number, name, phone_number, birth_date, address, email, zodiac, status` 且不含密碼欄；錯誤時顯示 `user.errors`。驗證：手動操作 new/edit 頁面可正常送出與顯示驗證錯誤。
- [x] 2.2 [P] 依「唯讀會員詳情頁」決策建立唯讀 `app/views/admin/users/show.html.erb`，顯示 `id_number, name, phone_number, birth_date, sex, address, email, zodiac, status`（`sex`／`zodiac`／`status` 以中文 i18n 顯示），不含密碼欄與內嵌編輯/刪除操作。驗證：手動開啟某會員詳情頁可見完整基本資料且無密碼欄。
- [x] 2.3 [P] 依「視圖與 i18n」決策在 `app/views/admin/users/index.html.erb` 頁首加「新增會員」按鈕連到 `new_admin_user_path`，並在每列加「檢視」連到 `admin_user_path(user)`、「編輯」連到 `edit_admin_user_path(user)`、「刪除」以 `button_to method: :delete` 搭配 `turbo_confirm` 確認對話框連到 `admin_user_path(user)`。驗證：手動檢視列表頁可見四類按鈕，刪除會跳出確認對話框。

## 3. i18n 文案

- [x] 3.1 [P] 依「視圖與 i18n」決策在 `config/locales/zh-TW.yml` 補上新增/編輯/刪除成功與「禁止刪除自己的帳號」之 flash 文案鍵值。驗證：`bin/rails runner 'I18n.t(...)'` 對新增鍵值回傳對應中文字串而非 translation missing。

## 4. 測試

- [x] 4.1 撰寫 `spec/requests/admin/users_spec.rb` request spec，涵蓋 "Admin creates a member from the member list"、"Admin views a member detail page"、"Admin edits an existing member"、"Admin deletes a member with a self-deletion guard" 的成功與失敗路徑，並斷言自動產生密碼後 `encrypted_password` 非空、show 頁回 200 且不含密碼欄位、自我刪除被擋。驗證：`bundle exec rspec spec/requests/admin/users_spec.rb` 全數通過。
- [x] 4.2 執行 `bin/rubocop` 確保新增與修改之檔案符合 rails-omakase 風格。驗證：`bin/rubocop` 無 offense。
