## Why

會員列表（member index）目前在表格中顯示 `email` 欄位，但 email 屬於選填且多數會員未填寫，佔用版面卻無實際價值。同時搜尋表單使用 `auto-fill` 自動排版，欄位數會隨視窗寬度浮動，版面不穩定。需要讓列表更聚焦於核心會員資料，並讓搜尋表單以固定每列 3 欄呈現，使版面一致可預期。

## What Changes

- 會員列表表格不再顯示 `email` 欄位（表頭與資料列皆移除），其餘欄位順序與內容維持不變。
- `email` 仍保留於會員詳細頁、新增/編輯表單與 Excel 匯出，不受本次變更影響。
- 搜尋表單由目前的 `auto-fill` 自適應排版改為固定每列 3 欄，5 個搜尋欄位以 3 + 2 方式排列。

## Non-Goals (optional)

- 不調整會員列表的欄位排序、分頁、搜尋條件或匯出邏輯。
- 不變更詳細頁、表單或匯出中對 `email` 的顯示。
- 不新增或移除任何搜尋欄位，只調整搜尋表單的版面欄數。

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `member-management`: 新增「會員列表顯示欄位排除 email」與「搜尋表單每列固定 3 欄」兩項列表呈現需求。

## Impact

- Affected specs: `member-management`
- Affected code:
  - Modified:
    - app/controllers/admin/users_controller.rb（`display_order_columns` 移除 `:email`）
    - app/assets/stylesheets/admin.css（`.search-grid` 改為每列 3 欄）
  - New: (none)
  - Removed: (none)
