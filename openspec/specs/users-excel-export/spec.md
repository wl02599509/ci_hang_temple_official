## ADDED Requirements

### Requirement: Export button availability
The system SHALL display an export button on the admin users index page that is accessible to authenticated administrators.

#### Scenario: Export button is visible to authenticated admin
- **WHEN** an authenticated administrator views the admin users index page
- **THEN** the system displays an "Export" button or form

#### Scenario: Export button is not accessible to unauthenticated users
- **WHEN** an unauthenticated user attempts to access the export functionality
- **THEN** the system redirects to the login page

### Requirement: Fixed column export
The system SHALL export all available user columns in a predefined order.

#### Scenario: Export includes all columns
- **WHEN** an administrator initiates an export
- **THEN** the system exports all available columns (status, name, id_number, sex, birth_date, zodiac, address, email) in the predefined order

### Requirement: Filter integration
The system SHALL respect current Ransack search and filter parameters when exporting user records.

#### Scenario: Export filtered results
- **WHEN** an administrator applies search filters (e.g., search by name or status)
- **THEN** the system exports only users matching the current filter criteria

#### Scenario: Export without filters
- **WHEN** an administrator exports without applying any filters
- **THEN** the system exports all user records

#### Scenario: Export with multiple filters
- **WHEN** an administrator applies multiple filters (e.g., status AND date range)
- **THEN** the system exports users matching all active filter criteria

### Requirement: Excel file generation
The system SHALL generate a valid Excel (.xlsx) file containing the exported user data.

#### Scenario: Successful Excel generation
- **WHEN** an administrator requests an export
- **THEN** the system generates a downloadable .xlsx file with proper Excel formatting

#### Scenario: Excel file has headers
- **WHEN** the Excel file is generated
- **THEN** the first row contains localized column headers using `User.human_attribute_name`

#### Scenario: Excel file has data rows
- **WHEN** the Excel file is generated with user records
- **THEN** each subsequent row contains user data for all columns in the correct order

#### Scenario: Excel file naming
- **WHEN** the Excel file is downloaded
- **THEN** the filename follows the format defined in I18n configuration (人員資料)

### Requirement: Data accuracy
The system SHALL ensure exported data matches the current state of user records in the database.

#### Scenario: Export reflects current data
- **WHEN** an administrator exports user records
- **THEN** the Excel file contains the most recent data from the database

#### Scenario: Enum values are exported correctly
- **WHEN** the Excel file includes enum fields (status, sex, zodiac)
- **THEN** the system exports the human-readable values or appropriate representations

### Requirement: Export performance
The system SHALL complete exports synchronously within a reasonable timeframe for typical datasets.

#### Scenario: Export completes for typical dataset
- **WHEN** an administrator exports up to 1000 user records
- **THEN** the system generates the file and initiates download within 5 seconds

#### Scenario: Export does not timeout
- **WHEN** an administrator exports filtered user records
- **THEN** the system completes the export without request timeout errors

### Requirement: Security and authorization
The system SHALL enforce authentication and authorization for all export operations.

#### Scenario: Authenticated users can export
- **WHEN** an authenticated administrator accesses the export endpoint
- **THEN** the system processes the export request

#### Scenario: Unauthenticated requests are rejected
- **WHEN** an unauthenticated request is made to the export endpoint
- **THEN** the system returns a 401 Unauthorized or redirects to login

#### Scenario: Export respects user permissions
- **WHEN** the export functionality is accessed
- **THEN** the system verifies the user has admin privileges before processing
