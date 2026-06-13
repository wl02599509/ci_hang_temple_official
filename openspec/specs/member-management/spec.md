# member-management Specification

## Purpose

TBD - created by archiving change 'member-list-crud-actions'. Update Purpose after archive.

## Requirements

### Requirement: Admin creates a member from the member list

The system SHALL allow an authenticated admin to create a new member record from the member list page. The create form SHALL collect `id_number`, `name`, `phone_number`, `birth_date`, `address`, `email`, `zodiac`, and `status`. The system SHALL NOT ask the admin for a password; it SHALL auto-generate a secure random password to satisfy the Devise `database_authenticatable` requirement. `sex` SHALL continue to be derived from `id_number` by the existing `set_sex` callback.

#### Scenario: Successful creation

- **WHEN** an authenticated admin submits the new-member form with a valid, unique `id_number` and all required fields
- **THEN** the system creates the user with an auto-generated random password and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已建立`

#### Scenario: Validation failure re-renders the form

- **WHEN** an authenticated admin submits the new-member form with an invalid or duplicate `id_number` (or a missing required field)
- **THEN** the system re-renders the new-member form with HTTP status 422 and shows the validation error messages, and creates no record

#### Scenario: New-member button is visible on the list

- **WHEN** an authenticated admin views the member list page
- **THEN** the page header shows a "新增會員" button linking to the new-member form


<!-- @trace
source: member-list-crud-actions
updated: 2026-06-14
code:
  - app/models/user.rb
  - app/controllers/admin/users/registrations_controller.rb
  - config/locales/zh-TW.yml
  - app/views/admin/users/registrations/edit.html.erb
  - app/views/admin/users/_form.html.erb
  - app/views/admin/users/new.html.erb
  - app/assets/stylesheets/admin.css
  - app/controllers/admin/users_controller.rb
  - app/views/admin/users/edit.html.erb
  - config/routes.rb
  - app/views/admin/users/index.html.erb
  - app/views/admin/users/registrations/new.html.erb
  - app/views/admin/users/show.html.erb
tests:
  - spec/features/admin/user_sign_up_spec.rb
  - spec/models/user_spec.rb
  - spec/requests/admin/users_spec.rb
-->

---
### Requirement: Admin edits an existing member

The system SHALL allow an authenticated admin to edit an existing member's basic data (`id_number`, `name`, `phone_number`, `birth_date`, `address`, `email`, `zodiac`, `status`). The edit form SHALL NOT change the member's password. Updating without supplying a password SHALL NOT trigger a password-presence validation error.

#### Scenario: Successful update

- **WHEN** an authenticated admin submits the edit form with valid changes
- **THEN** the system updates the member record and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已更新`

#### Scenario: Validation failure re-renders the edit form

- **WHEN** an authenticated admin submits the edit form with invalid data
- **THEN** the system re-renders the edit form with HTTP status 422 and shows the validation error messages, leaving the record unchanged

#### Scenario: Edit button per row

- **WHEN** an authenticated admin views the member list
- **THEN** each member row shows an "編輯" button linking to that member's edit form


<!-- @trace
source: member-list-crud-actions
updated: 2026-06-14
code:
  - app/models/user.rb
  - app/controllers/admin/users/registrations_controller.rb
  - config/locales/zh-TW.yml
  - app/views/admin/users/registrations/edit.html.erb
  - app/views/admin/users/_form.html.erb
  - app/views/admin/users/new.html.erb
  - app/assets/stylesheets/admin.css
  - app/controllers/admin/users_controller.rb
  - app/views/admin/users/edit.html.erb
  - config/routes.rb
  - app/views/admin/users/index.html.erb
  - app/views/admin/users/registrations/new.html.erb
  - app/views/admin/users/show.html.erb
tests:
  - spec/features/admin/user_sign_up_spec.rb
  - spec/models/user_spec.rb
  - spec/requests/admin/users_spec.rb
-->

---
### Requirement: Admin views a member detail page

The system SHALL allow an authenticated admin to view a read-only detail page for a single member. The page SHALL display the member's full basic data: `id_number`, `name`, `phone_number`, `birth_date`, `sex`, `address`, `email`, `zodiac`, and `status`. The detail page SHALL NOT display the password or any Devise credential fields, and SHALL NOT provide inline edit or delete controls.

#### Scenario: Successful view of a member

- **WHEN** an authenticated admin opens a member's detail page
- **THEN** the system shows that member's `id_number`, `name`, `phone_number`, `birth_date`, `sex`, `address`, `email`, `zodiac`, and `status`, with no password field shown

#### Scenario: View button per row

- **WHEN** an authenticated admin views the member list
- **THEN** each member row shows a "檢視" button linking to that member's detail page


<!-- @trace
source: member-list-crud-actions
updated: 2026-06-14
code:
  - app/models/user.rb
  - app/controllers/admin/users/registrations_controller.rb
  - config/locales/zh-TW.yml
  - app/views/admin/users/registrations/edit.html.erb
  - app/views/admin/users/_form.html.erb
  - app/views/admin/users/new.html.erb
  - app/assets/stylesheets/admin.css
  - app/controllers/admin/users_controller.rb
  - app/views/admin/users/edit.html.erb
  - config/routes.rb
  - app/views/admin/users/index.html.erb
  - app/views/admin/users/registrations/new.html.erb
  - app/views/admin/users/show.html.erb
tests:
  - spec/features/admin/user_sign_up_spec.rb
  - spec/models/user_spec.rb
  - spec/requests/admin/users_spec.rb
-->

---
### Requirement: Admin deletes a member with a self-deletion guard

The system SHALL allow an authenticated admin to delete a member record after a front-end confirmation dialog. The system SHALL NOT allow an admin to delete the account they are currently signed in as. An attempt to delete one's own account SHALL be rejected and SHALL leave the record intact.

#### Scenario: Successful deletion of another member

- **WHEN** an authenticated admin confirms deletion of a member that is not their own account
- **THEN** the system deletes the member record and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已刪除`

##### Example: delete success message

- **GIVEN** a member with status `善信大德` (normal), name `王小明`, id_number `A12345678`
- **WHEN** the admin deletes that member
- **THEN** the success flash message reads `善信大德王小明(A12345678)資料已刪除`

#### Scenario: Self-deletion is blocked

- **WHEN** an authenticated admin attempts to delete the account they are currently signed in as
- **THEN** the system does not delete the record, redirects back to the member list page, and shows an error message explaining that deleting one's own account is not allowed

#### Scenario: Delete requires confirmation

- **WHEN** an authenticated admin clicks the "刪除" button on a member row
- **THEN** the browser shows a confirmation dialog, and deletion proceeds only if the admin confirms

<!-- @trace
source: member-list-crud-actions
updated: 2026-06-14
code:
  - app/models/user.rb
  - app/controllers/admin/users/registrations_controller.rb
  - config/locales/zh-TW.yml
  - app/views/admin/users/registrations/edit.html.erb
  - app/views/admin/users/_form.html.erb
  - app/views/admin/users/new.html.erb
  - app/assets/stylesheets/admin.css
  - app/controllers/admin/users_controller.rb
  - app/views/admin/users/edit.html.erb
  - config/routes.rb
  - app/views/admin/users/index.html.erb
  - app/views/admin/users/registrations/new.html.erb
  - app/views/admin/users/show.html.erb
tests:
  - spec/features/admin/user_sign_up_spec.rb
  - spec/models/user_spec.rb
  - spec/requests/admin/users_spec.rb
-->