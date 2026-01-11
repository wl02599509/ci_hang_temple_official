# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ci Hang Temple Official is a Rails 8.1 application for managing temple member records. The application uses PostgreSQL, Devise for authentication, and ViewComponent for reusable UI components.

**Key Technologies:**
- Ruby 4.0.0
- Rails 8.1.1
- PostgreSQL database
- Bun for JavaScript bundling (not npm/yarn)
- TailwindCSS 4.x for styling
- Hotwire (Turbo + Stimulus)
- ViewComponent for encapsulated view components
- RSpec for testing with FactoryBot, Faker, and Shoulda Matchers

## Development Commands

### Setup
```bash
bin/setup                    # Initial setup: installs dependencies, prepares database, starts server
bin/setup --reset            # Reset database during setup
bin/setup --skip-server      # Setup without starting server
```

### Running the Application
```bash
bin/dev                      # Start all services (Rails server, JS build, CSS build) via Procfile
bin/rails server             # Start only Rails server (port 3000)
```

### Database
```bash
bin/rails db:prepare         # Create database and run migrations
bin/rails db:migrate         # Run pending migrations
bin/rails db:rollback        # Rollback last migration
bin/rails db:reset           # Drop, create, and migrate database
bin/rails db:seed            # Run seed data
```

### Testing
```bash
bundle exec rspec                        # Run all tests
bundle exec rspec spec/models/           # Run all model tests
bundle exec rspec spec/models/user_spec.rb           # Run specific test file
bundle exec rspec spec/models/user_spec.rb:10        # Run specific test at line 10
```

Code coverage reports are automatically generated in `coverage/` directory. Open `coverage/index.html` to view detailed coverage.

### Code Quality
```bash
bin/rubocop                  # Run RuboCop linter (follows rubocop-rails-omakase)
bin/rubocop -a               # Auto-fix RuboCop issues
bin/rubocop spec/            # Lint only spec files
bin/brakeman                 # Security vulnerability scanner
bin/bundler-audit            # Check for vulnerable gem versions
```

### Asset Building
```bash
bun install                  # Install JavaScript dependencies (use bun, not npm/yarn)
bun run build                # Build JavaScript assets once
bun run build --watch        # Watch and rebuild JavaScript
bun run build:css            # Build CSS assets once
bun run build:css -- --watch # Watch and rebuild CSS
```

Note: The project uses Bun instead of npm or yarn. Always use `bun` commands for JavaScript package management.

## Architecture

### Authentication System

The application uses Devise with a custom authentication flow for User model:
- **Authentication key**: `id_number` (Taiwan ID number, not email)
- **User routes**: Namespaced under `/admin/users`
- **Custom controllers**: `Admin::Users::SessionsController`, `Admin::Users::PasswordsController`, `Admin::Users::RegistrationsController`
- **Email not required**: The User model overrides `email_required?` to return false

### User Model Enums

The User model uses several enums defined in app/models/user.rb:

- `sex`: `male: 1`, `female: 2` (auto-set from ID number)
- `status`: `normal: 99`
- `zodiac`: Chinese zodiac signs (mice, ox, tiger, rabbit, dragon, snake, horse, goat, monkey, rooster, dog, pig)

### ID Number Format

Taiwan ID numbers have specific validation rules:
- Must start with uppercase letter
- Gender is determined by 2nd character (extracted in `set_sex` callback)
- Automatically converted to uppercase via custom setter

### ViewComponent Architecture

The project uses ViewComponent for reusable UI components located in `app/components/`:
- Components follow the pattern: `component_name.rb` + `component_name.html.erb`
- Example: `flash_component.rb` + `flash_component.html.erb`

### Admin Namespace

Admin features are organized under the `Admin` namespace:
- Routes: `/admin/*`
- Controllers: `app/controllers/admin/`
- Root: `admin/dashboard#index`
- Devise authentication paths are under `/admin/users`

### Configuration

The project uses the `config` gem for environment-specific settings:
- Main config: `config/settings.yml`
- Environment overrides: `config/settings/development.yml`, `config/settings/production.yml`, `config/settings/test.yml`
- Local overrides: `config/settings.local.yml` (gitignored)

### Testing Setup

RSpec is configured with:
- **FactoryBot**: For test data creation (use `create(:user)` or `build(:user)`)
- **Faker**: For generating realistic fake data
- **Shoulda Matchers**: For concise validation and association matchers
- **DatabaseCleaner**: For maintaining clean state between tests
- **SimpleCov**: For code coverage analysis

Refer to `spec/README.md` (written in Traditional Chinese) for detailed testing examples.

## Database Schema

The `users` table includes:
- `id_number` (unique, not null) - Taiwan ID number used for authentication
- `name`, `phone_number`, `birth_date`, `address` (required fields)
- `email` (optional, validated format when present)
- `sex` (enum: 1=male, 2=female, auto-populated from ID number)
- `zodiac` (enum: Chinese zodiac, nullable)
- `status` (enum: default 99=normal)
- Standard Devise fields: `encrypted_password`, `reset_password_token`, `remember_created_at`

## Important Patterns

### Custom Devise Authentication
When working with authentication, remember that this app uses `id_number` instead of email as the primary authentication key. Email validation is optional and bypassed via overridden Devise methods.

### Enum Usage
When adding or modifying enums, follow the existing pattern:
```ruby
enum :field_name, { value1: 1, value2: 2 }, validate: true
# or for nullable:
enum :field_name, { value1: 1 }, validate: { allow_nil: true }
```

### Running Tests Before Commits
The project uses RuboCop with rails-omakase style guide. Always run linting before committing:
```bash
bin/rubocop
```
