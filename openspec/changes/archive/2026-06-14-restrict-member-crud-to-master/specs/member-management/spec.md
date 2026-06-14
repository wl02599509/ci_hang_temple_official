## ADDED Requirements

### Requirement: Authorization restricts member write actions to 宮主 (master)

The system SHALL authorize member write actions (`new`, `create`, `edit`, `update`, `destroy`) using a Pundit `UserPolicy`, and SHALL permit them only when the signed-in user's `status` is `master` (宮主). Read actions (`index`, `show`, `export`) SHALL remain available to every authenticated user regardless of `status`. When an authenticated non-master user attempts a write action, the system SHALL NOT modify any record; it SHALL redirect to the member list page with an HTTP redirect (302) and SHALL show an error flash message indicating insufficient permission.

#### Scenario: 宮主 performs write actions

- **WHEN** a signed-in user whose `status` is `master` opens the new-member or edit form, or submits a create, update, or delete request
- **THEN** the system authorizes the action and processes it normally

#### Scenario: Non-master is denied a write action

- **WHEN** a signed-in user whose `status` is not `master` requests any write action route (`new`, `create`, `edit`, `update`, or `destroy`) directly
- **THEN** the system does not create, update, or delete any record, redirects to the member list page, and shows an error flash message indicating the user lacks permission

#### Scenario: Non-master can still read

- **WHEN** a signed-in user whose `status` is not `master` views the member list, opens a member detail page, or triggers the export
- **THEN** the system serves the requested read action normally

##### Example: write authorization by status

| Signed-in user status | Action            | Outcome                                  |
| --------------------- | ----------------- | ---------------------------------------- |
| master                | create / update / destroy | authorized, processed normally    |
| normal                | create / update / destroy | denied, redirect to list with alert |
| member                | edit form (GET)   | denied, redirect to list with alert      |
| normal                | index / show / export | allowed                              |

## MODIFIED Requirements

### Requirement: Admin creates a member from the member list

The system SHALL allow an admin whose `status` is `master` (宮主) to create a new member record from the member list page. The create form SHALL collect `id_number`, `name`, `phone_number`, `birth_date`, `address`, `email`, `zodiac`, and `status`. The system SHALL NOT ask the admin for a password; it SHALL auto-generate a secure random password to satisfy the Devise `database_authenticatable` requirement. `sex` SHALL continue to be derived from `id_number` by the existing `set_sex` callback. The "新增會員" button SHALL be shown only to a signed-in user authorized by `UserPolicy#create?` (i.e. a `master`).

#### Scenario: Successful creation

- **WHEN** a signed-in master admin submits the new-member form with a valid, unique `id_number` and all required fields
- **THEN** the system creates the user with an auto-generated random password and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已建立`

#### Scenario: Validation failure re-renders the form

- **WHEN** a signed-in master admin submits the new-member form with an invalid or duplicate `id_number` (or a missing required field)
- **THEN** the system re-renders the new-member form with HTTP status 422 and shows the validation error messages, and creates no record

#### Scenario: New-member button visibility depends on authorization

- **WHEN** a signed-in master admin views the member list page
- **THEN** the page header shows a "新增會員" button linking to the new-member form
- **AND** when the signed-in user is not a master, the "新增會員" button is not shown

### Requirement: Admin edits an existing member

The system SHALL allow an admin whose `status` is `master` (宮主) to edit an existing member's basic data (`id_number`, `name`, `phone_number`, `birth_date`, `address`, `email`, `zodiac`, `status`). The edit form SHALL NOT change the member's password. Updating without supplying a password SHALL NOT trigger a password-presence validation error. The per-row "編輯" button SHALL be shown only to a signed-in user authorized by `UserPolicy#edit?` (i.e. a `master`).

#### Scenario: Successful update

- **WHEN** a signed-in master admin submits the edit form with valid changes
- **THEN** the system updates the member record and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已更新`

#### Scenario: Validation failure re-renders the edit form

- **WHEN** a signed-in master admin submits the edit form with invalid data
- **THEN** the system re-renders the edit form with HTTP status 422 and shows the validation error messages, leaving the record unchanged

#### Scenario: Edit button visibility depends on authorization

- **WHEN** a signed-in master admin views the member list
- **THEN** each member row shows an "編輯" button linking to that member's edit form
- **AND** when the signed-in user is not a master, the "編輯" button is not shown

### Requirement: Admin deletes a member with a self-deletion guard

The system SHALL allow an admin whose `status` is `master` (宮主) to delete a member record after a front-end confirmation dialog. The system SHALL NOT allow an admin to delete the account they are currently signed in as. An attempt to delete one's own account SHALL be rejected and SHALL leave the record intact. The per-row "刪除" button SHALL be shown only to a signed-in user authorized by `UserPolicy#destroy?` (i.e. a `master`).

#### Scenario: Successful deletion of another member

- **WHEN** a signed-in master admin confirms deletion of a member that is not their own account
- **THEN** the system deletes the member record and redirects to the member list page
- **AND** the success flash message identifies the member as `<status-label><name>(<id_number>)資料已刪除`

##### Example: delete success message

- **GIVEN** a member with status `善信大德` (normal), name `王小明`, id_number `A12345678`
- **WHEN** a signed-in master admin deletes that member
- **THEN** the success flash message reads `善信大德王小明(A12345678)資料已刪除`

#### Scenario: Self-deletion is blocked

- **WHEN** a signed-in master admin attempts to delete the account they are currently signed in as
- **THEN** the system does not delete the record, redirects back to the member list page, and shows an error message explaining that deleting one's own account is not allowed

#### Scenario: Delete button visibility and confirmation

- **WHEN** a signed-in master admin clicks the "刪除" button on a member row
- **THEN** the browser shows a confirmation dialog, and deletion proceeds only if the admin confirms
- **AND** when the signed-in user is not a master, the "刪除" button is not shown
