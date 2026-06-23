## ADDED Requirements

### Requirement: Member list table excludes the email column

The member list (index) table SHALL display member columns in the order `status`, `name`, `id_number`, `sex`, `birth_date`, `zodiac`, `address`, and SHALL NOT include an `email` column in either the table header or the data rows. The `email` field SHALL continue to be displayed on the member detail page, in the new and edit member forms, and in the Excel export; this requirement affects only the index list table.

#### Scenario: Email column absent from the member list

- **WHEN** an authenticated admin views the member list
- **THEN** the table shows the `status`, `name`, `id_number`, `sex`, `birth_date`, `zodiac`, and `address` columns
- **AND** no `email` column header or `email` cell is rendered in any member row

#### Scenario: Email still shown outside the list

- **WHEN** an authenticated admin opens a member's detail page or the Excel export
- **THEN** that member's `email` value is still displayed

### Requirement: Member search form uses a fixed three-column layout

The member list search form SHALL arrange its search fields in a grid of exactly three columns per row, regardless of viewport width. With the current five search fields (`status_eq`, `name_cont`, `id_number_start`, `sex_eq`, `zodiac_eq`), the fields SHALL flow as three fields on the first row and two fields on the second row. The set of search fields SHALL NOT change as part of this requirement.

#### Scenario: Search fields laid out three per row

- **WHEN** an authenticated admin views the member list search form
- **THEN** the search fields are arranged in a grid of three columns per row
- **AND** the five existing search fields appear as three on the first row and two on the second row
