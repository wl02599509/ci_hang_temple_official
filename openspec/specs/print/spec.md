# print Specification

## Purpose

TBD - created by archiving change 'add-print-abstraction'. Update Purpose after archive.

## Requirements

### Requirement: Print sidebar entry

The admin sidebar SHALL display a "列印作業" (Print) entry that links to the print overview page at `/admin/print`. The entry SHALL be highlighted as active when the current page belongs to the print controller.

#### Scenario: Authenticated admin sees the print entry

- **WHEN** an authenticated admin views any admin page
- **THEN** the sidebar shows a "列印作業" entry linking to `/admin/print`

#### Scenario: Entry highlights on the overview page

- **WHEN** an authenticated admin is on `/admin/print`
- **THEN** the "列印作業" sidebar entry is rendered in the active state


<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->

---
### Requirement: Print overview page

The system SHALL provide an overview page at `/admin/print` that lists every registered print item as a card showing its title and description, with each card linking to that item's own URL. The overview page SHALL require an authenticated admin. When no print items are registered, the page SHALL display an empty-state message instead of cards.

#### Scenario: Overview lists registered items

- **WHEN** an authenticated admin opens `/admin/print` and one or more print items are registered
- **THEN** the page returns HTTP 200 and renders one card per registered item, each linking to that item's path

#### Scenario: Overview shows empty state

- **WHEN** an authenticated admin opens `/admin/print` and no print items are registered
- **THEN** the page returns HTTP 200 and shows an empty-state message and renders no item cards

#### Scenario: Unauthenticated access is redirected

- **WHEN** an unauthenticated user requests `/admin/print`
- **THEN** the system redirects them to the sign-in page


<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->

---
### Requirement: Print registry

The system SHALL provide a registry that loads print item definitions from a single configuration source. Each definition SHALL expose `slug`, `title`, `description`, and `path`. The registry SHALL provide a way to list all definitions and to look up a single definition by `slug`, returning nothing when the slug is unknown.

#### Scenario: List all definitions

- **WHEN** the registry is asked for all definitions
- **THEN** it returns one definition object per configured item, each exposing slug, title, description, and path

#### Scenario: Look up by slug

- **WHEN** the registry is asked for a definition by a slug
- **THEN** it returns the matching definition if the slug is registered, and returns nothing if the slug is not registered

##### Example: registry lookup

| Input slug | Registered slugs | Result |
| ---------- | ---------------- | ------ |
| "roster" | ["roster"] | the "roster" definition |
| "unknown" | ["roster"] | nothing (nil) |


<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->

---
### Requirement: Abstract print base controller

The system SHALL provide an abstract base controller for print items that all item controllers inherit from. The base controller SHALL require an authenticated admin and SHALL provide two shared behaviors: rendering an upload form that accepts `.xlsx` and `.csv` files, and accepting an uploaded file to render a print preview using the print layout. Subclasses SHALL only need to declare their print template and how parsed rows map to view data. When no file is submitted or parsing fails, the controller SHALL redirect back to the upload form and display an error message rather than raising an unhandled exception.

#### Scenario: Render upload form

- **WHEN** an authenticated admin opens a print item's upload page
- **THEN** the system renders an upload form that accepts `.xlsx` and `.csv` files

#### Scenario: Generate print preview from uploaded file

- **WHEN** an authenticated admin submits a supported `.xlsx` or `.csv` file to a print item
- **THEN** the system parses the file into rows, maps them to the item's view data, and renders the item's print template using the print layout

#### Scenario: Missing or invalid file

- **WHEN** an authenticated admin submits the preview request with no file or with a file that cannot be parsed
- **THEN** the system redirects back to the upload form and displays an error message without raising an unhandled exception


<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->

---
### Requirement: Uploaded file parsing

The system SHALL provide a file parsing service that converts an uploaded `.xlsx` or `.csv` file into a uniform list of rows, where each row is a list of cell values. The parser SHALL select its parsing strategy from the file extension. The parser SHALL raise a clear error for unsupported file extensions.

#### Scenario: Parse csv into rows

- **WHEN** the parser receives a `.csv` file
- **THEN** it returns a list of rows where each row is a list of cell values

#### Scenario: Parse xlsx into rows

- **WHEN** the parser receives an `.xlsx` file
- **THEN** it returns a list of rows in the same row structure as csv parsing

#### Scenario: Reject unsupported extension

- **WHEN** the parser receives a file whose extension is neither `.xlsx` nor `.csv`
- **THEN** it raises a clear error indicating the file type is unsupported

##### Example: equivalent csv and xlsx output

- **GIVEN** a csv file and an xlsx file each containing rows: ["name","age"], ["Amy","30"]
- **WHEN** each file is parsed
- **THEN** both produce rows: [["name","age"], ["Amy","30"]]


<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->

---
### Requirement: Print preview triggered via browser print

The system SHALL provide a dedicated print layout and a client-side mechanism so that a print preview page exposes a print button which, when clicked, opens the browser's native print preview via JavaScript `window.print()`. The print layout SHALL hide non-content elements such as the print button when printing.

#### Scenario: Print button opens browser print preview

- **WHEN** an admin clicks the print button on a print preview page
- **THEN** the browser's native print preview is opened via `window.print()`

#### Scenario: Print layout hides controls when printing

- **WHEN** the print preview page is printed
- **THEN** non-content controls such as the print button are hidden in the printed output

<!-- @trace
source: add-print-abstraction
updated: 2026-10-24
code:
  - app/views/layouts/print.html.erb
  - app/javascript/controllers/index.js
  - app/javascript/controllers/print_controller.js
  - app/models/print/registry.rb
  - app/services/print/file_parser.rb
  - config/routes.rb
  - spec/fixtures/views/admin/print/sample/preview.html.erb
  - config/admin/print.yml
  - app/assets/stylesheets/admin.css
  - app/models/print/definition.rb
  - app/controllers/admin/print/base_controller.rb
  - app/views/admin/print/base/show.html.erb
  - app/views/admin/print/index.html.erb
  - app/controllers/admin/print_controller.rb
  - config/admin/sidebar.yml
  - Gemfile
  - Gemfile.lock
tests:
  - spec/requests/admin/print/base_spec.rb
  - spec/services/print/file_parser_spec.rb
  - spec/requests/admin/print_spec.rb
  - spec/models/print/registry_spec.rb
-->