## 1. 列表呈現調整

- [x] [P] 1.1 實作需求 "Member list table excludes the email column"：在 app/controllers/admin/users_controller.rb 的 `display_order_columns` 移除 `:email`，使其回傳 `%i[status name id_number sex birth_date zodiac address]`。完成後會員列表（app/views/admin/users/index.html.erb）的表頭與資料列皆不再出現 email 欄位。驗證：以管理員身分開啟 `/admin/users`，確認表格無 email 欄；同時確認詳細頁、新增/編輯表單與 Excel 匯出仍顯示 email。
- [x] [P] 1.2 實作需求 "Member search form uses a fixed three-column layout"：在 app/assets/stylesheets/admin.css 將 `.search-grid` 的 `grid-template-columns` 由 `repeat(auto-fill, minmax(200px, 1fr))` 改為 `repeat(3, 1fr)`，使搜尋表單固定每列 3 欄。完成後 5 個搜尋欄位以第一列 3 欄、第二列 2 欄排列。驗證：開啟 `/admin/users`，於桌面寬度下確認搜尋表單每列顯示 3 個欄位。

## 2. 驗證

- [x] 2.1 執行 `bundle exec rspec spec/requests/admin/users_spec.rb` 與 `bundle exec rspec spec/features` 中與會員列表相關的測試，確認列表與搜尋變更未造成既有測試失敗；若有測試斷言 email 出現在列表表格中，更新該斷言為不應出現。執行 `bin/rubocop app/controllers/admin/users_controller.rb` 確認無 lint 問題。
