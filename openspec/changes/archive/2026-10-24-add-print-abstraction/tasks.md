## 1. 依賴與註冊設定

- [x] 1.1 [P] 新增 `roo` gem 並 `bundle install`,使應用程式具備讀取 xlsx 的能力(對應設計決策「統一的 xlsx/csv 檔案解析服務(新增 roo gem)」)。驗證:`bundle exec ruby -e "require 'roo'"` 不報錯,`Gemfile.lock` 含 roo。
- [x] 1.2 [P] 新增 `config/admin/print.yml` 作為列印項目註冊來源(對應設計決策「以 registry 設定檔註冊列印項目」),格式對齊 `sidebar.yml`,本次先放空清單或停用的範例註解。驗證:`YAML.load_file` 能載入且結構為可迭代清單。

## 2. Print registry 與檔案解析(先寫測試)

- [x] 2.1 撰寫 `Print::Registry` 與 `Print::Definition` 的 spec:`all` 回傳每個設定項目對應的 definition(含 slug/title/description/path),`find(slug)` 命中回 definition、未命中回 nil(對應需求 Print registry)。驗證:`bundle exec rspec` 中該檔先紅。
- [x] 2.2 實作 `Print::Definition`(承載 slug/title/description/path)與 `Print::Registry`(自 `config/admin/print.yml` 載入,提供 `all`/`find`),使 2.1 測試轉綠(對應需求 Print registry、設計決策「以 registry 設定檔註冊列印項目」)。驗證:`bundle exec rspec spec/models/print/registry_spec.rb` 全綠。
- [x] 2.3 撰寫 `Print::FileParser` 的 spec:csv 與 xlsx 解析出相同 rows 結構,不支援副檔名拋出明確錯誤(對應需求 Uploaded file parsing)。驗證:該 spec 先紅,含 fixture csv/xlsx。
- [x] 2.4 實作 `Print::FileParser`,依副檔名以 `roo`(xlsx)或標準庫 `CSV`(csv)解析為 `Array<Array>`,不支援副檔名拋錯,使 2.3 轉綠(對應需求 Uploaded file parsing、設計決策「統一的 xlsx/csv 檔案解析服務(新增 roo gem)」)。驗證:`bundle exec rspec spec/services/print/file_parser_spec.rb` 全綠。

## 3. 抽象基底 controller

- [x] 3.1 實作 `Admin::Print::BaseController`,要求管理員驗證,提供 `show`(渲染接受 .xlsx/.csv 的上傳表單)與 `preview`(解析檔案→映射 rows 至 view 資料→以 `print` layout 渲染子類別版型);無檔或解析失敗時導回上傳表單並顯示錯誤 flash,不丟未處理例外(對應需求 Abstract print base controller、設計決策「抽象基底 controller 封裝上傳與預覽流程」)。驗證:以測試用範例子類別撰寫 request spec 涵蓋 show/preview/錯誤三情境,`bundle exec rspec` 綠。

## 4. 總覽頁、路由與 sidebar 入口

- [x] 4.1 新增 `/admin/print` 路由指向 `Admin::PrintController#index`,僅本次的總覽頁路由,項目路由保留給後續 propose(對應設計決策「路由策略:總覽頁固定、項目路由由後續 propose 各自加入」)。驗證:`bin/rails routes | grep print` 顯示 index 路由。
- [x] 4.2 實作 `Admin::PrintController#index` 與 `app/views/admin/print/index.html.erb`:列出 `Print::Registry.all` 卡片並連到各 path,無項目時顯示空狀態(對應需求 Print overview page)。驗證:request spec — 已驗證管理員 GET 回 200 且列出項目/空狀態,未驗證者導向登入,`bundle exec rspec` 綠。
- [x] 4.3 在 `config/admin/sidebar.yml` 新增「列印作業」入口(path `/admin/print`,`controller_name: print`),使其顯示並在總覽頁高亮(對應需求 Print sidebar entry)。驗證:手動於後台確認 sidebar 出現入口並於 `/admin/print` 高亮。

## 5. 列印 layout 與 JS 列印觸發

- [x] 5.1 [P] 新增 `app/views/layouts/print.html.erb` 列印專用 layout,含列印按鈕,並以 `@media print` 隱藏按鈕等非列印元素(對應需求 Print preview triggered via browser print、設計決策「列印專用 layout 與 Stimulus print_controller 觸發瀏覽器列印」)。驗證:手動列印預覽時僅顯示內容、按鈕被隱藏。
- [x] 5.2 [P] 新增 Stimulus `print_controller.js`(`print` action 呼叫 `window.print()`)並於 `app/javascript/controllers/index.js` 註冊,按鈕以 `data-action="click->print#print"` 綁定(對應需求 Print preview triggered via browser print)。驗證:點擊列印按鈕可開啟瀏覽器列印預覽。

## 6. 整合驗證

- [x] 6.1 執行完整測試與 lint,確保抽象層交付且符合風格(對應需求 Abstract print base controller)。驗證:`bundle exec rspec` 全綠且 `bin/rubocop` 無違規。
