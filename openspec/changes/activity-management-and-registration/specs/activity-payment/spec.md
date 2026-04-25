## ADDED Requirements

### Requirement: Mark Registrations as Paid via Modal

The system SHALL allow admin to mark multiple selected registrations as paid.

Clicking "繳費" SHALL open a modal with:
- A required dropdown for payment method: 轉帳 (`transfer`) or 現金 (`cash`)
- A required text field for collector (收款人)

On confirmation:
- All selected registrations with status `pending` SHALL have status set to `paid`
- `payment_method`, `collector`, and `paid_at` SHALL be recorded
- Registrations with status `cancelled` or already `paid` in the selection SHALL be ignored

#### Scenario: Successful batch payment

- **WHEN** admin selects one or more `pending` registrations, fills in payment method and collector, and confirms
- **THEN** those registrations SHALL have status set to `paid`
- **THEN** `payment_method`, `collector`, and `paid_at` SHALL be recorded on each
- **THEN** the registrations list SHALL reflect the updated status

#### Scenario: Already paid or cancelled are skipped

- **WHEN** admin selects registrations that include `paid` or `cancelled` status
- **THEN** those registrations SHALL be skipped without error
- **THEN** only `pending` registrations SHALL be updated to `paid`

#### Scenario: Payment method is required

- **WHEN** admin clicks confirm without selecting a payment method
- **THEN** the system SHALL NOT submit the form
- **THEN** the modal SHALL display a validation error on the payment method field

#### Scenario: Collector is required

- **WHEN** admin clicks confirm without entering a collector name
- **THEN** the system SHALL NOT submit the form
- **THEN** the modal SHALL display a validation error on the collector field
