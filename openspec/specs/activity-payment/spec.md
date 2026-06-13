# activity-payment Specification

## Purpose

TBD - created by archiving change 'activity-management-and-registration'. Update Purpose after archive.

## Requirements

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

<!-- @trace
source: activity-management-and-registration
updated: 2026-06-13
code:
  - app/views/admin/activities/payments/pay.turbo_stream.erb
  - app/views/admin/activities/registrations/_pay_modal.html.erb
  - spec/factories/users.rb
  - app/views/admin/activities/registrations/user_search.html.erb
  - app/views/admin/activities/edit.html.erb
  - .spectra.yaml
  - app/views/admin/activities/index.html.erb
  - db/migrate/20260425004202_create_activities.rb
  - app/views/admin/activities/registrations/_registration_row.html.erb
  - app/views/admin/activities/registrations/_register_modal.html.erb
  - app/javascript/controllers/modal_controller.js
  - app/models/activity_registration.rb
  - app/javascript/controllers/registration_form_controller.js
  - db/migrate/20260425004239_create_activity_registrations.rb
  - app/views/admin/activities/registrations/cancel.turbo_stream.erb
  - app/views/admin/activities/registrations/index.html.erb
  - app/views/admin/activities/registrations/cancel_modal.html.erb
  - db/migrate/20260425010012_create_active_storage_tables.active_storage.rb
  - app/views/admin/activities/registrations/_user_search_results.html.erb
  - config/locales/zh-TW.yml
  - config/routes.rb
  - spec/factories/activity_registrations.rb
  - app/views/admin/activities/show.html.erb
  - app/views/admin/activities/registrations/_cancel_modal.html.erb
  - app/views/admin/activities/registrations/create.turbo_stream.erb
  - spec/support/capybara.rb
  - app/views/admin/activities/new.html.erb
  - app/controllers/admin/activities_controller.rb
  - app/views/admin/activities/_form.html.erb
  - spec/factories/activities.rb
  - spec/support/devise.rb
  - app/controllers/admin/activities/registrations_controller.rb
  - config/admin/sidebar.yml
  - app/javascript/controllers/index.js
  - db/schema.rb
  - app/views/admin/activities/registrations/new_modal.html.erb
  - app/controllers/admin/activities/payments_controller.rb
  - CLAUDE.md
  - app/views/admin/activities/registrations/pay_modal.html.erb
  - app/models/activity.rb
tests:
  - spec/features/admin/activities/registrations_spec.rb
  - spec/models/activity_registration_spec.rb
  - spec/requests/admin/activities/registrations_spec.rb
  - spec/models/activity_spec.rb
  - spec/requests/admin/activities/payments_spec.rb
  - spec/requests/admin/activities_spec.rb
-->