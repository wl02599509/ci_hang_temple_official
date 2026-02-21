## Context

The application currently displays user records in a paginated table view at `/admin/users` with search/filter capabilities via Ransack. The controller uses the `display_order_columns` helper method to define which columns are shown: `status`, `name`, `id_number`, `sex`, `birth_date`, `zodiac`, `address`, `email`.

Temple administrators need to export filtered user data to Excel for offline reporting and external sharing. The export must respect the current Ransack search parameters to allow exporting specific subsets of users.

**Current Stack:**
- Rails 8.1.2 with Turbo and Stimulus (Hotwire)
- TailwindCSS for styling
- Ransack for search/filtering
- Pagy for pagination

**Constraints:**
- Must work with existing Devise authentication
- Must integrate with existing admin namespace
- Should maintain consistency with current UI/UX patterns
- Excel file generation should not block the request (reasonable performance for typical datasets)

## Goals / Non-Goals

**Goals:**
- Add Excel export capability to the admin users index page
- Export respects current Ransack search/filter parameters
- Export all available user columns in predefined order
- Generate `.xlsx` files with proper formatting and headers
- Maintain security (only authenticated admin users can export)

**Non-Goals:**
- Background job processing (initial implementation will be synchronous)
- Export history or saved export configurations
- Support for other formats (CSV, PDF) - Excel only for now
- Bulk export across multiple pages beyond filtered results

## Decisions

### 1. Excel Generation Library: caxlsx + caxlsx_rails

**Decision:** Use `caxlsx` gem (modern fork of axlsx) with `caxlsx_rails` for Rails integration.

**Rationale:**
- `caxlsx` is actively maintained and supports modern Ruby versions
- `caxlsx_rails` provides Rails integration with `.xlsx.axlsx` template rendering
- Generates true Excel files (.xlsx) with formatting support
- Well-documented and widely used in Rails community

**Alternatives Considered:**
- `spreadsheet_architect`: More flexible but requires more boilerplate for column selection
- `xlsx_writer`: Lighter but less feature-rich, no Rails integration
- Built-in CSV: Doesn't meet requirement for Excel format (.xlsx)

### 2. Controller Action: New `export` Action in UsersController

**Decision:** Add `GET /admin/users/export` route and action to existing `Admin::UsersController`.

**Rationale:**
- RESTful approach - export is a read operation
- Keeps export logic close to index logic (reuses Ransack query building)
- GET allows bookmarking and easier testing
- Query params contain Ransack filters

**Implementation Pattern:**
```ruby
def export
  @q = User.ransack(params[:q])
  @users = @q.result.order(status: :asc)

  respond_to do |format|
    format.xlsx do
      render xlsx: 'export', filename: I18n.t('export.filename.users')
    end
  end
end
```

**Alternatives Considered:**
- POST request: Less RESTful for read operations, harder to bookmark
- Separate ExportsController: Overkill for single export feature
- Service object: May be beneficial later, but unnecessary for initial implementation
- Filename: Use I18n for the name config, and the name is 人員資料

### 4. Template: AXLSX Template File

**Decision:** Use `app/views/admin/users/export.xlsx.axlsx` template file.

**Rationale:**
- Separates presentation logic from controller
- `caxlsx_rails` provides clean template DSL
- Easy to maintain and modify formatting
- Follows Rails conventions

**Template Structure:**
- Header row with localized column names (using `User.human_attribute_name`)
- Data rows iterating over filtered users
- Basic styling (bold headers, auto-width columns)

### 5. Performance: Synchronous Export (Initial Implementation)

**Decision:** Process exports synchronously in the request cycle (no background jobs initially).

**Rationale:**
- Simpler implementation for MVP
- Temple member records are likely small-to-medium dataset (hundreds to low thousands)
- Ransack filters typically reduce result set size
- Can migrate to background processing if performance becomes an issue

**When to Revisit:**
- If exports exceed 10,000 records regularly
- If export generation takes >5 seconds consistently
- If users request export scheduling or email delivery

**Alternatives Considered:**
- Sidekiq/Active Job: Adds complexity and infrastructure requirements
- Email delivery: Requires additional UX for notification

## Risks / Trade-offs

### Risk: Large Dataset Performance
**Mitigation:**
- Start with synchronous implementation
- Monitor performance in production
- Add pagination limit or export warnings if needed
- Consider background jobs only if necessary

### Risk: Memory Usage with Full Table Scans
**Mitigation:**
- Use `find_each` or `in_batches` if performance issues arise
- Export respects filters, so full table scans are unlikely
- Document recommended practice of filtering before exporting

## Migration Plan

**Deployment Steps:**
1. Add gems: `caxlsx` and `caxlsx_rails` to Gemfile
2. Run `bundle install`
3. Add route: `get 'export', to: 'users#export'` in admin users scope
4. Implement controller action
5. Create AXLSX template
6. Add export form/button to index view
7. Test with filtered and unfiltered exports
8. Deploy to production (no database changes required)

**Rollback Strategy:**
- Feature is additive (no schema changes)
- Simply remove route and UI elements if needed
- No data migration or cleanup required

## Open Questions

None - design is ready for implementation.
