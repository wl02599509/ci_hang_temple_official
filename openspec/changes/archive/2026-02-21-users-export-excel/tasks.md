## 1. Dependencies Setup

- [x] 1.1 Add `caxlsx` gem to Gemfile
- [x] 1.2 Add `caxlsx_rails` gem to Gemfile
- [x] 1.3 Run `bundle install` to install gems

## 2. I18n Configuration

- [x] 2.1 Add `export.filename.users` key to I18n locale files (zh-TW) with value "人員資料"
- [x] 2.2 Verify I18n configuration loads correctly

## 3. Routes Configuration

- [x] 3.1 Add `get 'export', to: 'users#export'` route in admin users scope in `config/routes.rb`
- [x] 3.2 Verify route exists by running `bin/rails routes | grep export`

## 4. Controller Implementation

- [x] 4.1 Add `export` action to `app/controllers/admin/users_controller.rb`
- [x] 4.2 Implement Ransack query building with `params[:q]`
- [x] 4.3 Order results by `status: :asc`
- [x] 4.4 Add `respond_to` block with `format.xlsx`
- [x] 4.5 Configure render with xlsx format and I18n filename

## 5. Excel Template Creation

- [x] 5.1 Create directory `app/views/admin/users/` if it doesn't exist
- [x] 5.2 Create `app/views/admin/users/export.xlsx.axlsx` template file
- [x] 5.3 Implement header row with localized column names using `User.human_attribute_name`
- [x] 5.4 Implement data rows iterating over `@users` with all columns
- [x] 5.5 Add basic styling (bold headers, auto-width columns)
- [x] 5.6 Ensure columns are in correct order: status, name, id_number, sex, birth_date, zodiac, address, email

## 6. UI Implementation

- [x] 6.1 Add export button to `app/views/admin/users/index.html.erb`
- [x] 6.2 Position export button near search form for UX consistency
- [x] 6.3 Create link/button that points to `admin_users_export_path` with current Ransack params
- [x] 6.4 Style button with TailwindCSS to match existing UI patterns
- [x] 6.5 Ensure button is visible when users are present

## 7. Enum Value Handling

- [x] 7.1 Verify enum values (status, sex, zodiac) export as human-readable values
- [x] 7.2 Use I18n or enum humanize methods for proper display

## 8. Testing

- [x] 8.1 Test export with no filters (exports all users)
- [x] 8.2 Test export with single filter (e.g., by status)
- [x] 8.3 Test export with multiple filters (e.g., status AND name search)
- [x] 8.4 Verify Excel file downloads with correct filename (人員資料)
- [x] 8.5 Open Excel file and verify header row has localized column names
- [x] 8.6 Verify data rows contain correct user data in correct order
- [x] 8.7 Verify enum values display properly (not raw integer values)
- [x] 8.8 Test unauthenticated access redirects to login
- [x] 8.9 Test performance with typical dataset (verify completes within 5 seconds)

## 9. Code Quality

- [x] 9.1 Run RuboCop and fix any linting issues: `bin/rubocop`
- [x] 9.2 Review code for security issues with Brakeman: `bin/brakeman`
- [x] 9.3 Ensure proper authentication check (already handled by `before_action :authenticate_user!`)
