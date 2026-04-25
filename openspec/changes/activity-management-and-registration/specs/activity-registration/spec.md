## ADDED Requirements

### Requirement: View Registration List

The system SHALL display all registered users for an activity on the registrations page, accessed by clicking "報名與繳費" from the activity list.

The list SHALL display the following columns in order: checkbox (for multi-select), name, status, id_number, sex, zodiac, birth_date, phone_number, registration status, payment status.

#### Scenario: View registrations

- **WHEN** admin clicks "報名與繳費" on an activity row
- **THEN** the system SHALL render the registrations page for that activity
- **THEN** all registered users SHALL be listed with the specified columns

---

### Requirement: Register Users via Modal

The system SHALL provide a "報名" button on the registrations page that opens a modal.

The modal SHALL allow admin to:
1. Search users by name or id_number (real-time, via Turbo Frame request)
2. Select multiple users via checkboxes
3. Confirm to register all selected users to the activity

The system SHALL ignore activity `status` and registration period dates when processing admin registrations.

The system SHALL NOT register a user who is already registered (non-cancelled) for the same activity.

#### Scenario: Register new users

- **WHEN** admin searches, selects users in the modal, and clicks confirm
- **THEN** each selected user SHALL have an `ActivityRegistration` created with status `pending`
- **THEN** already-registered users (non-cancelled) SHALL be skipped without error
- **THEN** the registrations list SHALL be updated to include the newly registered users

#### Scenario: Search users in modal

- **WHEN** admin types in the search field inside the registration modal
- **THEN** the system SHALL display matching users (by name or id_number substring) via Turbo Frame
- **THEN** previously selected checkboxes SHALL remain checked

---

### Requirement: Cancel Registration via Modal

The system SHALL allow admin to cancel registrations for multiple selected users.

Clicking "取消報名" SHALL open a modal with:
- A required text field for cancellation reason
- A conditional refund amount field (decimal, optional): displayed only when at least one selected registration has status `paid`
- A warning message when the selection includes both `paid` and `pending` registrations: "多選的報名者中有未繳費者，退費金額不會套用於未繳費者"

On confirmation:
- All selected registrations SHALL have status set to `cancelled`
- `cancel_reason` and `cancelled_at` SHALL be recorded for all cancelled registrations
- `refund_amount` and `refunded_at` SHALL be recorded only for registrations that were `paid`

The system SHALL only process registrations with status `pending` or `paid`; already-cancelled registrations in the selection SHALL be ignored.

#### Scenario: Cancel pending registrations

- **WHEN** admin selects users with status `pending` and confirms cancellation with a reason
- **THEN** those registrations SHALL be set to `cancelled` with `cancel_reason` and `cancelled_at` recorded
- **THEN** no refund fields SHALL be recorded

#### Scenario: Cancel paid registrations with refund

- **WHEN** admin selects users with status `paid`, enters a reason and refund amount, and confirms
- **THEN** those registrations SHALL be set to `cancelled`
- **THEN** `cancel_reason`, `cancelled_at`, `refund_amount`, and `refunded_at` SHALL be recorded

#### Scenario: Mixed selection (paid and pending) with refund amount entered

- **WHEN** admin selects both `pending` and `paid` users and enters a refund amount
- **THEN** the warning message SHALL be displayed in the modal
- **THEN** on confirmation, `paid` registrations SHALL record the refund amount
- **THEN** `pending` registrations SHALL NOT have `refund_amount` or `refunded_at` recorded

#### Scenario: Cancel reason is required

- **WHEN** admin clicks confirm without entering a cancellation reason
- **THEN** the system SHALL NOT submit the form
- **THEN** the modal SHALL display a validation error on the reason field
