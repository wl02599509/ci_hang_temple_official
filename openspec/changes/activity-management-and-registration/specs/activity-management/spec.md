## ADDED Requirements

### Requirement: Create Activity

The system SHALL allow admin users to create a new activity with the following fields:
- `title` (string, required): activity topic name
- `description` (text, required): activity description
- `notes` (text, optional): additional remarks
- `event_date` (date, required): the date the activity takes place
- `registration_start_date` (date, required): start of registration period
- `registration_end_date` (date, required): end of registration period
- `fee` (decimal, required, >= 0): activity fee in NTD
- `status` (enum, required): `draft` (default) or `published`
- `photos` (attachments, optional): one or more image files via Active Storage

The system SHALL default `status` to `draft` upon creation.

#### Scenario: Successful creation

- **WHEN** admin submits a valid activity form
- **THEN** the activity SHALL be saved to the database with status `draft`
- **THEN** the admin SHALL be redirected to the activity list page

#### Scenario: Missing required fields

- **WHEN** admin submits the form with any required field blank
- **THEN** the system SHALL re-render the form with validation error messages
- **THEN** no activity SHALL be persisted

#### Scenario: registration_end_date before registration_start_date

- **WHEN** admin submits a form where `registration_end_date` is before `registration_start_date`
- **THEN** the system SHALL display a validation error on `registration_end_date`

---

### Requirement: Edit Activity

The system SHALL allow admin users to edit all fields of an existing activity, including replacing or adding photos.

#### Scenario: Successful edit

- **WHEN** admin submits a valid edit form
- **THEN** the activity record SHALL be updated
- **THEN** the admin SHALL be redirected to the activity list page

---

### Requirement: Activity List

The system SHALL display all activities in descending order by `event_date` on the list page.

The list SHALL display the following columns in order: title, event_date, registration period (start–end), published status, fee.

#### Scenario: List renders correctly

- **WHEN** admin visits the activities index page
- **THEN** all activities SHALL be shown, ordered by `event_date` descending

---

### Requirement: Activity List Search by Title

The system SHALL support fuzzy search on `title` (matching any substring, case-insensitive).

#### Scenario: Partial title match

- **WHEN** admin enters a partial title string and submits the search form
- **THEN** the list SHALL show only activities whose title contains that string
- **THEN** activities not matching SHALL be excluded

---

### Requirement: Activity List Search by ROC Year

The system SHALL support filtering activities by the ROC (Republic of China) year of `event_date`.

The system SHALL convert the user-entered ROC year to the Gregorian year by adding 1911 before querying.

#### Scenario: ROC year filter

- **WHEN** admin enters ROC year (e.g., 113) in the year search field
- **THEN** the system SHALL query for activities where `event_date` falls in Gregorian year 2024 (113 + 1911)
- **THEN** only matching activities SHALL be displayed

---

### Requirement: View Activity Detail

The system SHALL provide a read-only detail view for each activity showing all fields and attached photos.

#### Scenario: View activity

- **WHEN** admin clicks the "檢視" button on an activity row
- **THEN** the system SHALL render the activity detail page with all fields and photos

---

### Requirement: Activity List Row Actions

Each row in the activity list SHALL include three action buttons: 編輯, 檢視, 報名與繳費.

#### Scenario: Action buttons present

- **WHEN** admin views the activity list
- **THEN** each activity row SHALL display 編輯, 檢視, and 報名與繳費 buttons
