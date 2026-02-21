## 1. 相依套件設定

- [x] 1.1 在 Gemfile 中新增 `caxlsx` gem
- [x] 1.2 在 Gemfile 中新增 `caxlsx_rails` gem
- [x] 1.3 執行 `bundle install` 安裝 gem

## 2. I18n 組態

- [x] 2.1 在 I18n 語言檔(zh-TW)中新增 `export.filename.users` 鍵,值為「人員資料」
- [x] 2.2 驗證 I18n 組態正確載入

## 3. 路由組態

- [x] 3.1 在 `config/routes.rb` 的 admin users 範圍中新增 `get 'export', to: 'users#export'` 路由
- [x] 3.2 執行 `bin/rails routes | grep export` 驗證路由存在

## 4. 控制器實作

- [x] 4.1 在 `app/controllers/admin/users_controller.rb` 中新增 `export` 動作
- [x] 4.2 使用 `params[:q]` 實作 Ransack 查詢建構
- [x] 4.3 以 `status: :asc` 排序結果
- [x] 4.4 新增帶有 `format.xlsx` 的 `respond_to` 區塊
- [x] 4.5 設定使用 xlsx 格式和 I18n 檔案名稱的渲染

## 5. Excel 範本建立

- [x] 5.1 如果 `app/views/admin/users/` 目錄不存在,則建立該目錄
- [x] 5.2 建立 `app/views/admin/users/export.xlsx.axlsx` 範本檔案
- [x] 5.3 使用 `User.human_attribute_name` 實作帶有本地化欄位名稱的標題列
- [x] 5.4 實作迭代 `@users` 並包含所有欄位的資料列
- [x] 5.5 新增基本樣式(粗體標題、自動欄寬)
- [x] 5.6 確保欄位順序正確:status、name、id_number、sex、birth_date、zodiac、address、email

## 6. UI 實作

- [x] 6.1 在 `app/views/admin/users/index.html.erb` 中新增匯出按鈕
- [x] 6.2 將匯出按鈕放在搜尋表單附近以保持 UX 一致性
- [x] 6.3 建立指向 `admin_users_export_path` 並帶有目前 Ransack 參數的連結/按鈕
- [x] 6.4 使用 TailwindCSS 設定按鈕樣式以符合現有 UI 模式
- [x] 6.5 確保在有人員時按鈕可見

## 7. 列舉值處理

- [x] 7.1 驗證列舉值(status、sex、zodiac)匯出為人類可讀的值
- [x] 7.2 使用 I18n 或列舉人性化方法進行適當顯示

## 8. 測試

- [x] 8.1 測試無篩選的匯出(匯出所有人員)
- [x] 8.2 測試單一篩選的匯出(例如,依狀態篩選)
- [x] 8.3 測試多重篩選的匯出(例如,狀態 AND 姓名搜尋)
- [x] 8.4 驗證 Excel 檔案以正確檔名下載(人員資料)
- [x] 8.5 開啟 Excel 檔案並驗證標題列有本地化的欄位名稱
- [x] 8.6 驗證資料列包含正確順序的正確人員資料
- [x] 8.7 驗證列舉值正確顯示(非原始整數值)
- [x] 8.8 測試未驗證存取重導向至登入頁面
- [x] 8.9 使用一般資料集測試效能(驗證在 5 秒內完成)

## 9. 程式碼品質

- [x] 9.1 執行 RuboCop 並修正任何 linting 問題:`bin/rubocop`
- [x] 9.2 使用 Brakeman 審查程式碼的安全問題:`bin/brakeman`
- [x] 9.3 確保適當的身分驗證檢查(已由 `before_action :authenticate_user!` 處理)
