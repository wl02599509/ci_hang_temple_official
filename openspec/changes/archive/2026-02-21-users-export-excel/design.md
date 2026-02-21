## 背景

應用程式目前在 `/admin/users` 以分頁表格方式顯示人員記錄,並透過 Ransack 提供搜尋/篩選功能。控制器使用 `display_order_columns` 輔助方法定義顯示的欄位:`status`、`name`、`id_number`、`sex`、`birth_date`、`zodiac`、`address`、`email`。

廟方管理員需要將篩選後的人員資料匯出至 Excel,以便離線報告和外部分享。匯出必須遵循目前的 Ransack 搜尋參數,以允許匯出特定的人員子集。

**目前技術堆疊:**
- Rails 8.1.2 搭配 Turbo 和 Stimulus (Hotwire)
- TailwindCSS 用於樣式
- Ransack 用於搜尋/篩選
- Pagy 用於分頁

**限制條件:**
- 必須與現有的 Devise 身分驗證整合
- 必須整合至現有的 admin 命名空間
- 應保持與目前 UI/UX 模式的一致性
- Excel 檔案生成不應阻塞請求(對於一般資料集應有合理的效能)

## 目標 / 非目標

**目標:**
- 在管理後台人員列表頁面新增 Excel 匯出功能
- 匯出遵循目前的 Ransack 搜尋/篩選參數
- 以預定義順序匯出所有可用的人員欄位
- 生成具有適當格式和標題的 `.xlsx` 檔案
- 維持安全性(僅已驗證的管理員使用者可以匯出)

**非目標:**
- 背景工作處理(初始實作將是同步的)
- 匯出歷史記錄或儲存的匯出組態
- 支援其他格式(CSV、PDF)- 目前僅支援 Excel
- 超出篩選結果的多頁批次匯出

## 決策

### 1. Excel 生成函式庫:caxlsx + caxlsx_rails

**決策:** 使用 `caxlsx` gem(axlsx 的現代分支)搭配 `caxlsx_rails` 進行 Rails 整合。

**理由:**
- `caxlsx` 持續維護且支援現代 Ruby 版本
- `caxlsx_rails` 提供 Rails 整合與 `.xlsx.axlsx` 範本渲染
- 生成真正的 Excel 檔案(.xlsx)並支援格式化
- 文件完善且在 Rails 社群中廣泛使用

**考慮過的替代方案:**
- `spreadsheet_architect`:更靈活但欄位選擇需要更多樣板程式碼
- `xlsx_writer`:較輕量但功能較少,無 Rails 整合
- 內建 CSV:不符合 Excel 格式(.xlsx)需求

### 2. 控制器動作:在 UsersController 中新增 `export` 動作

**決策:** 在現有的 `Admin::UsersController` 中新增 `GET /admin/users/export` 路由和動作。

**理由:**
- RESTful 方法 - 匯出是讀取操作
- 將匯出邏輯放在列表邏輯附近(重用 Ransack 查詢建構)
- GET 允許書籤和更容易測試
- 查詢參數包含 Ransack 篩選器

**實作模式:**
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

**考慮過的替代方案:**
- POST 請求:對於讀取操作較不 RESTful,較難加入書籤
- 獨立的 ExportsController:對於單一匯出功能來說過於複雜
- 服務物件:稍後可能有益,但初始實作不必要
- 檔案名稱:使用 I18n 進行名稱設定,名稱為「人員資料」

### 4. 範本:AXLSX 範本檔案

**決策:** 使用 `app/views/admin/users/export.xlsx.axlsx` 範本檔案。

**理由:**
- 將呈現邏輯與控制器分離
- `caxlsx_rails` 提供簡潔的範本 DSL
- 易於維護和修改格式
- 遵循 Rails 慣例

**範本結構:**
- 帶有本地化欄位名稱的標題列(使用 `User.human_attribute_name`)
- 迭代篩選後使用者的資料列
- 基本樣式(粗體標題、自動欄寬)

### 5. 效能:同步匯出(初始實作)

**決策:** 在請求週期中同步處理匯出(初期不使用背景工作)。

**理由:**
- MVP 實作較簡單
- 廟方成員記錄可能是中小型資料集(數百到數千筆)
- Ransack 篩選器通常會減少結果集大小
- 如果效能成為問題,可以遷移到背景處理

**何時重新審視:**
- 如果匯出經常超過 10,000 筆記錄
- 如果匯出生成持續超過 5 秒
- 如果使用者要求匯出排程或電子郵件傳送

**考慮過的替代方案:**
- Sidekiq/Active Job:增加複雜性和基礎設施需求
- 電子郵件傳送:需要額外的通知 UX

## 風險 / 取捨

### 風險:大型資料集效能
**緩解措施:**
- 從同步實作開始
- 在正式環境中監控效能
- 如有需要,新增分頁限制或匯出警告
- 僅在必要時考慮背景工作

### 風險:完整表格掃描的記憶體使用
**緩解措施:**
- 如果出現效能問題,使用 `find_each` 或 `in_batches`
- 匯出遵循篩選器,因此不太可能進行完整表格掃描
- 記錄建議在匯出前先進行篩選的最佳實踐

## 遷移計畫

**部署步驟:**
1. 在 Gemfile 中新增 gem:`caxlsx` 和 `caxlsx_rails`
2. 執行 `bundle install`
3. 在 admin users 範圍中新增路由:`get 'export', to: 'users#export'`
4. 實作控制器動作
5. 建立 AXLSX 範本
6. 在列表視圖中新增匯出表單/按鈕
7. 測試有篩選和無篩選的匯出
8. 部署到正式環境(不需要資料庫變更)

**回滾策略:**
- 功能是附加的(無結構描述變更)
- 如需要,只需移除路由和 UI 元素
- 不需要資料遷移或清理

## 待解決問題

無 - 設計已準備好實作。
