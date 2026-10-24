## Context

後台(`Admin` namespace)將陸續加入多個「列印作業」項目,共通流程一致:管理員在某個項目頁上傳資料檔(xlsx/csv)→ 系統解析成資料列 → 套用該項目專屬版型渲染 → 透過瀏覽器列印預覽輸出。目前專案僅有 `caxlsx`(寫出 xlsx),沒有讀取 xlsx 的能力;sidebar 由 `config/admin/sidebar.yml` 驅動;controller 採 `Admin::` namespace,路由集中於 `config/routes.rb`。本次先建立抽象層,讓未來每個項目只需提供「版型 + 資料對應 + 一筆註冊定義 + 一條路由」即可掛載,不重複造輪子。

命名約定:抽象層的程式 identifier 一律使用 `print`(namespace 為 `Print` / `Admin::Print`),刻意避開 `job`/`Job`,以免與 Sidekiq job 概念混淆。

## Goals / Non-Goals

**Goals:**

- 在 sidebar 提供「列印作業」入口,並有一個列出所有已註冊項目的總覽頁。
- 提供註冊機制(registry),新增項目時集中宣告 slug/標題/說明/controller。
- 提供抽象基底 controller,封裝「顯示上傳表單」與「接收檔案、解析、渲染列印預覽」的共通流程。
- 提供統一的 xlsx/csv 檔案解析服務,輸出一致的資料列結構供版型使用。
- 提供列印專用 layout 與 Stimulus controller,以 `window.print()` 觸發瀏覽器列印預覽。

**Non-Goals:**

- 不實作任何正式業務列印項目(報表、名冊、繳費單等);這些後續各自提出 propose。
- 不做伺服器端 PDF 產生;列印一律透過瀏覽器原生列印預覽。
- 不做上傳檔案的長期儲存或歷史紀錄;檔案僅在單次請求中即時解析,不落地保存。
- 不做欄位層級的資料驗證規則(由各項目自行定義);抽象層只保證能解析成資料列。

## Decisions

### 以 registry 設定檔註冊列印項目

新增 `config/admin/print.yml` 作為列印項目的註冊來源,結構與 `sidebar.yml` 一致(由初始化載入為常數或經 `Print::Registry` 讀取)。每筆定義包含 `slug`、`title`、`description`、`path`。`Print::Registry` 提供 `all`(回傳 `Print::Definition` 集合)與 `find(slug)`。總覽頁迭代 `Registry.all` 產生卡片連結。

理由:與既有 `sidebar.yml` 模式一致,新增項目時改一個 YAML 即可出現在總覽頁,降低樣板程式。替代方案:用 Ruby DSL 在 initializer 註冊 — 較彈性但與專案現有慣例不符,故不採用。本次抽象層先放 0 筆正式定義(或 1 筆停用的範例註解),由後續 propose 各自加入。

### 抽象基底 controller 封裝上傳與預覽流程

新增 `Admin::Print::BaseController`(繼承既有 admin 基底 controller,沿用驗證),提供兩個共通 action:`show`(渲染上傳表單)與 `preview`(接收上傳檔案 → 呼叫 `Print::FileParser` 解析 → 將資料列指派給 view → 以 `layout "print"` 渲染該項目的列印版型)。子類別只需覆寫「列印版型樣板路徑」與「將解析後資料列轉成版型所需 view 資料」的方法。

理由:共通流程集中於一處,未來項目 controller 僅 5~10 行。替代方案:用單一動態 controller 依 slug 切換版型 — 但各項目資料對應差異大,獨立子類別較清晰,故採繼承式抽象。

### 統一的 xlsx/csv 檔案解析服務(新增 roo gem)

新增 `Print::FileParser`,以上傳檔副檔名(`.xlsx` / `.csv`)決定解析方式:xlsx 透過 `roo` gem 讀取,csv 透過 Ruby 標準函式庫 `CSV`。輸出統一為資料列陣列(每列為字串/值的陣列,首列可視為表頭)。不支援的副檔名回傳明確錯誤。

理由:讀 xlsx 需要新依賴,`roo` 為 Rails 生態常見且維護良好;csv 用標準庫無需額外 gem。替代方案:要求一律轉 csv — 但使用者多以 xlsx 作業,體驗差,故支援兩者。

### 列印專用 layout 與 Stimulus print_controller 觸發瀏覽器列印

新增 `app/views/layouts/print.html.erb` 列印專用 layout(最小化、列印友善樣式,螢幕上顯示「列印」按鈕,`@media print` 隱藏非列印元素)。新增 Stimulus `print_controller.js`,其 `print` action 呼叫 `window.print()`;按鈕以 `data-action="click->print#print"` 綁定。於 `app/javascript/controllers/index.js` 註冊。

理由:符合需求「用 JS 打開電腦的列印預覽畫面」,且不依賴伺服器端列印。替代方案:在每個版型內嵌 inline `onclick="window.print()"` — 與專案 Hotwire/Stimulus 慣例不符,故用 Stimulus controller。

### 路由策略:總覽頁固定、項目路由由後續 propose 各自加入

本次只新增列印總覽頁路由(`Admin::PrintController#index`,路徑 `/admin/print`)。未來每個項目於其 propose 中,在 `admin` namespace 下新增自己的 `show`/`preview` 路由並指向繼承 `BaseController` 的子類別。sidebar 的「列印作業」入口指向 `/admin/print`,且 `controller_name` 設為 `print` 以正確高亮。

理由:項目 URL 各自獨立(符合需求),抽象層不預先綁死命名,保留彈性。

## Implementation Contract

**行為(Behavior):**

- 管理員登入後,sidebar 出現「列印作業」項目;點擊進入 `/admin/print`,當前頁高亮。
- 總覽頁列出 `Print::Registry.all` 的所有項目卡片(含標題、說明),每張卡片連到該項目的 `path`。當無已註冊項目時,顯示空狀態提示文字。
- 抽象層提供 `Admin::Print::BaseController`,子類別繼承後即具備:`show` 渲染上傳表單(接受 `.xlsx`/`.csv`);`preview` 接收上傳檔、解析為資料列、以 `print` layout 渲染子類別指定的列印版型。
- 列印預覽頁含「列印」按鈕,點擊後透過 Stimulus `print_controller` 呼叫 `window.print()` 開啟瀏覽器列印預覽;`@media print` 下僅顯示列印內容。

**介面 / 資料形狀(Interface / data shape):**

- `Print::Registry.all` → `Array<Print::Definition>`;`Print::Registry.find(slug)` → `Print::Definition | nil`。
- `Print::Definition` 屬性:`slug`、`title`、`description`、`path`。
- `Print::FileParser.new(uploaded_file).rows` → `Array<Array>`(每列為值陣列);副檔名以 `.xlsx`/`.csv` 判斷。
- `Admin::Print::BaseController` 子類別覆寫點:列印版型樣板路徑、由 rows 組成 view 資料的方法。

**失敗模式(Failure modes):**

- `FileParser` 遇到不支援副檔名 → 拋出明確錯誤(可被 controller 捕捉後以 flash 訊息提示)。
- `preview` 未附檔案或解析失敗 → 導回上傳表單並顯示錯誤 flash,不丟出未處理例外。

**驗收標準(Acceptance criteria):**

- RSpec(專案使用 RSpec + FactoryBot,遵循 tdd):
  - `Print::Registry` 能從 `config/admin/print.yml` 載入並回傳 `Definition` 集合,`find` 能依 slug 取得/找不到回 nil。
  - `Print::FileParser` 能將範例 csv 與 xlsx 解析為相同的資料列結構;不支援副檔名拋錯。
  - request spec:已驗證管理員 GET `/admin/print` 回 200 且列出已註冊項目(或空狀態);未驗證者被導向登入。
- 手動驗證:sidebar 出現「列印作業」並可進入總覽頁;以一個測試用範例子類別驗證上傳→預覽→列印按鈕可開啟 `window.print()`。
- `bin/rubocop` 通過(rails-omakase 風格)。

**範圍邊界(Scope boundaries):**

- In scope:sidebar 入口、總覽頁、registry、`Definition`、`FileParser`、`BaseController`、`print` layout、`print_controller.js`、roo gem、總覽頁路由、必要的測試。
- Out of scope:任何正式業務列印項目的版型與資料對應、項目自身路由、PDF 產生、檔案儲存、欄位驗證規則。

## Risks / Trade-offs

- [新增 roo 依賴增加 gem 體積與維護面] → roo 為成熟常用 gem;僅在列印作業解析時使用,影響範圍可控。
- [抽象層在無任何正式項目時難以端到端驗證] → 以測試用範例子類別 + request/unit spec 驗證抽象行為,確保介面契約可用。
- [子類別覆寫點若設計不當會導致未來項目要改基底] → 覆寫點限定在「版型路徑」與「rows→view 資料」兩處,範圍清楚;若後續發現需更多彈性,於該項目 propose 中再擴充基底。
- [瀏覽器列印樣式跨瀏覽器差異] → 以 `@media print` 控制並提供基本列印樣式;各項目可在自己的版型內補強。
