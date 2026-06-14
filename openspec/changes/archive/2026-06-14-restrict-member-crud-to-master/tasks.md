## 1. 安裝 Pundit 與授權基礎建設

- [x] 1.1 實作 design 決策「採用 Pundit 而非 CanCanCan 或自寫 before_action」：在 `Gemfile` 加入 `gem "pundit"` 並執行 `bundle install`，使 `Pundit` 常數可用。驗證：`bundle exec ruby -e "require 'pundit'"` 不報錯，且 `Gemfile.lock` 含 pundit。
- [x] 1.2 實作 design 決策「授權失敗以 rescue_from 轉為使用者友善導向」：在 `app/controllers/application_controller.rb` 加入 `include Pundit::Authorization`，並以 `rescue_from Pundit::NotAuthorizedError` 導向 `admin_users_path` 並帶 `alert`（i18n key `pundit.not_authorized`）。驗證：request spec 中非授權寫入請求回傳 302 導向會員列表且帶 alert，而非 500。
- [x] 1.3 建立 `app/policies/application_policy.rb` 作為標準 Pundit base policy（含 `Scope` 內部類別與預設 false 的動作方法）。驗證：`UserPolicy` 可繼承自它且 `bundle exec rspec spec/policies/user_policy_spec.rb` 載入無誤。

## 2. UserPolicy 授權規則

- [x] 2.1 實作 design 決策「以 UserPolicy 對應寫入動作，讀取動作一律放行」並滿足需求「Authorization restricts member write actions to 宮主 (master)」的讀取放行部分：建立 `app/policies/user_policy.rb`，`index?` 與 `show?` 回傳 `true`；`create?`、`update?`、`destroy?` 回傳 `user.master?`（`new?` 委派 `create?`、`edit?` 委派 `update?` 沿用 Pundit 預設）。驗證：`spec/policies/user_policy_spec.rb` 斷言 master user 對寫入動作為 true、非 master 為 false、讀取動作對所有 status 為 true，`bundle exec rspec spec/policies/user_policy_spec.rb` 全綠。

## 3. Controller 強制授權

- [x] 3.1 滿足需求「Authorization restricts member write actions to 宮主 (master)」的 controller 強制部分，並落實需求「Admin creates a member from the member list」「Admin edits an existing member」「Admin deletes a member with a self-deletion guard」的 master 限定行為人：在 `app/controllers/admin/users_controller.rb` 的 `new`、`create` 呼叫 `authorize User`，`edit`、`update`、`destroy` 呼叫 `authorize @user`，`index`、`show`、`export` 不加 `authorize`。驗證：`spec/requests/admin/users_spec.rb` 中非 master 對五個寫入路由皆 302 導回 `admin_users_path` 且無資料變動，master 可成功建立/更新/刪除。

## 4. UI 按鈕依授權顯示

- [x] 4.1 實作 design 決策「UI 按鈕以 policy 方法控制顯示」，落實需求「Admin creates a member from the member list」「Admin edits an existing member」「Admin deletes a member with a self-deletion guard」的按鈕可見性 scenario：在 `app/views/admin/users/index.html.erb` 用 `policy(User).create?` 包住「新增會員」按鈕、用 `policy(user).edit?`／`policy(user).destroy?` 包住每列「編輯」「刪除」按鈕，使非 master 看不到（「檢視」不受限）。驗證：spec 斷言非 master 列表頁不含新增/編輯/刪除按鈕，master 列表頁含這些按鈕。
- [x] 4.2 [P] 在 `app/views/admin/users/show.html.erb` 用對應 policy 方法包住詳情頁的編輯/刪除動作按鈕（若有），非 master 不顯示。驗證：spec 斷言非 master 的 show 頁不含編輯/刪除按鈕。

## 5. i18n 與測試收尾

- [x] 5.1 [P] 在 `config/locales` 的 zh-TW 檔新增 `pundit.not_authorized` 權限不足提示文案（繁體中文）。驗證：`I18n.t("pundit.not_authorized")` 回傳非 missing 字串，且授權失敗導向時 flash 顯示該文案。
- [x] 5.2 執行 `bundle exec rspec` 與 `bin/rubocop`，確認需求「Authorization restricts member write actions to 宮主 (master)」全部 scenario 對應測試通過、既有測試無回歸、lint 無誤。驗證：兩指令皆 exit 0。
