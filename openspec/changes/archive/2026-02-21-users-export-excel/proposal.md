## Why

Temple administrators need to export user records to Excel for reporting, data analysis, and sharing with external stakeholders. Currently, user data can only be viewed in the web interface, requiring manual copy-paste for offline use or reporting purposes.

## What Changes

- Add "Export" button on the admin users index page
- Allow administrators to export user records to Excel
- Generate Excel files (.xlsx) containing user data based on current search/filter criteria
- Export all standard user fields: status, name, ID number, sex, birth date, zodiac, address, email

## Capabilities

### New Capabilities
- `users-excel-export`: Export user records to Excel format with all columns and filtered results

### Modified Capabilities

(None - this is a new feature that doesn't modify existing functionality)

## Impact

**Code Changes:**
- `app/controllers/admin/users_controller.rb`: Add export action
- `app/views/admin/users/index.html.erb`: Add export button/form
- Routes: Add new route for export action

**Dependencies:**
- Add Excel generation gem (likely `caxlsx` and `caxlsx_rails`)

**User Experience:**
- Administrators will have a new export option on the users list page
- Export will respect current search/filter settings from Ransack
