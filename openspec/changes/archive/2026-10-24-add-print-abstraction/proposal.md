## Why

後台未來需要提供多個「列印作業」項目（例如各式報表、名冊、繳費單等），每個項目都遵循相同的操作流程:上傳資料檔（xlsx/csv）→ 系統解析 → 套用該項目專屬的列印版型 → 透過瀏覽器列印預覽輸出。若每個項目各自實作上傳、解析、列印觸發等共通邏輯,將造成大量重複程式碼且難以維護。因此先建立一個共用的抽象層,讓未來每個列印項目只需專注於「自己的版型與資料對應」即可掛載進來。

> 命名注意:抽象層的程式 identifier 一律使用 `print`(避免使用 `job`/`Job`,以免與 Sidekiq job 混淆)。

## What Changes

- 在後台 sidebar 新增「列印作業」入口,連到列印總覽頁 `/admin/print`。
- 新增列印總覽頁:列出所有已註冊的列印項目,每個項目為一張卡片並連到各自獨立的 URL。
- 建立列印項目的「註冊機制」(registry),未來新增項目時只需註冊一筆定義(slug、標題、說明、controller),即可出現在總覽頁。
- 建立抽象基底 controller `Admin::Print::BaseController`,提供共通流程:顯示上傳表單(show)、接收檔案並解析後渲染列印預覽(preview)。未來各項目的 controller 繼承此基底,只需指定自己的列印版型與資料對應。
- 建立共用檔案解析服務,將上傳的 xlsx/csv 解析為統一的資料列結構(rows)供版型使用;為此新增可讀取 xlsx 的 gem(`roo`),csv 使用 Ruby 標準函式庫。
- 建立列印專用 layout 與 Stimulus controller,提供「列印」按鈕,透過 JS `window.print()` 開啟瀏覽器列印預覽。
- 本次僅交付抽象層與一個可運作的範例骨架(不含任何正式業務項目);實際的列印項目將於後續各自提出 propose。

## Non-Goals (optional)

(none — Non-Goals 記錄於 design.md)

## Capabilities

### New Capabilities

- `print`: 後台列印作業的抽象層,涵蓋 sidebar 入口、列印項目總覽與註冊機制、共通的檔案上傳與解析流程、抽象基底 controller、列印專用 layout 與透過 JS 觸發瀏覽器列印預覽的能力。

### Modified Capabilities

(none)

## Impact

- Affected specs: 新增 `print` capability。
- Affected code:
  - New:
    - app/controllers/admin/print_controller.rb
    - app/controllers/admin/print/base_controller.rb
    - app/models/print/registry.rb
    - app/models/print/definition.rb
    - app/services/print/file_parser.rb
    - app/views/admin/print/index.html.erb
    - app/views/layouts/print.html.erb
    - app/javascript/controllers/print_controller.js
    - config/admin/print.yml
  - Modified:
    - config/routes.rb (新增 print 路由)
    - config/admin/sidebar.yml (新增「列印作業」入口)
    - app/javascript/controllers/index.js (註冊 print_controller)
    - Gemfile (新增 roo gem)
- Affected dependencies: 新增 `roo`(讀取 xlsx);csv 使用 Ruby 標準函式庫。
