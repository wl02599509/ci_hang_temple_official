## Why

宮廟目前缺乏統一的活動管理機制，無法在後台建立、管理活動，也無法替信眾辦理報名與繳費，導致相關作業仰賴人工紙本記錄，容易出錯且難以追蹤。

## What Changes

- 新增活動管理功能：後台人員可建立、編輯、瀏覽活動，包含活動日期、主題、描述、備註、費用、報名時間起迄、狀態（draft/published）與多張照片
- 新增活動報名功能：後台人員可替信眾報名任意活動（不受活動狀態與報名時間限制）
- 新增繳費記錄功能：可批次標記已報名者為「已繳費」，記錄繳費方式（轉帳/現金）與收款人
- 新增取消報名功能：可批次取消報名，填寫取消原因；若報名者已繳費則可同時記錄退費金額

## Capabilities

### New Capabilities

- `activity-management`: 活動的 CRUD 管理，含照片上傳、搜尋（主題名稱模糊搜尋、民國年份）、列表（依活動日期降冪排序）
- `activity-registration`: 後台人員替信眾報名活動、查看報名名單、批次取消報名（含退費記錄）
- `activity-payment`: 批次標記已報名者繳費狀態，記錄繳費方式與收款人

### Modified Capabilities

（無）

## Impact

- Affected specs: `activity-management`, `activity-registration`, `activity-payment`（均為新建）
- Affected code:
  - `app/models/activity.rb`（新增）
  - `app/models/activity_registration.rb`（新增）
  - `db/migrate/*_create_activities.rb`（新增）
  - `db/migrate/*_create_activity_registrations.rb`（新增）
  - `app/controllers/admin/activities_controller.rb`（新增）
  - `app/controllers/admin/activities/registrations_controller.rb`（新增）
  - `app/controllers/admin/activities/payments_controller.rb`（新增）
  - `app/views/admin/activities/`（新增）
  - `config/routes.rb`（修改，新增 admin namespace 下的 activities routes）
  - `app/javascript/controllers/`（新增 Stimulus controllers for modal 互動）
