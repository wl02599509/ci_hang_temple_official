## Context

後台目前使用自訂 CSS 檔案（`admin.css`）搭配少量 Tailwind utility class，整體色彩採用藍紫漸層（#667eea → #764ba2）。字型為英文優先的 system font stack，中文字型回退至系統預設字型，無法保證楷書或明體的顯示效果。

改造範圍集中在樣式層，不涉及任何 Rails 邏輯、路由或資料庫結構。

## Goals / Non-Goals

**Goals:**
- 將後台主色調替換為朱砂紅 + 金色的宮廟配色
- 整體背景換為米白色系，降低視覺疲勞
- 引入 Noto Serif TC（標題）與 Noto Sans TC（內文）強化中文閱讀體驗
- 改動範圍最小化，只動 `admin.css` 與 admin layout

**Non-Goals:**
- 不改動前台樣式（`application.tailwind.css`）
- 不引入新的 CSS framework 或套件
- 不調整 HTML 結構與 class 名稱
- 不加入裝飾性圖案（祥雲、八卦紋等）

## Decisions

### 決策 1：只換色彩，不換 CSS 架構

繼續使用現有 `admin.css` 自訂 CSS，不切換至純 Tailwind utility class。

**理由**：現有 CSS 結構清晰、class 命名有語意（`.admin-header`、`.sidebar-nav` 等），改色彩只需局部替換，不需重寫 HTML。若切換至 Tailwind，需要大量修改 view 檔案，超出本次範圍。

**備選方案考慮**：引入 CSS custom properties（`--primary-color`）讓主題切換更彈性，但目前只有一套主題，過早抽象化，暫不採用。

### 決策 2：使用 Google Fonts 引入中文字型

在 admin layout `<head>` 加入 Google Fonts CDN 的 Noto Serif TC 與 Noto Sans TC。

**理由**：無需額外 gem 或 bun 套件，部署簡單。Noto TC 系列對宮廟後台的繁體中文顯示效果佳，且為開源字型。

**備選方案考慮**：使用本地字型檔案（woff2）可避免 CDN 依賴，但字型檔案體積大（數 MB），增加 assets 負擔，暫不採用。

### 決策 3：色彩系統以朱砂紅為主，金色為輔

| 用途 | 顏色 | Hex |
|------|------|-----|
| Header / 主色 | 朱砂紅 | `#9B2335` |
| Active / 深色 | 深紅褐 | `#6B1C2A` |
| Accent / 金色 | 金 | `#C9A14A` |
| 整體背景 | 米白 | `#FAF7F2` |
| 邊框分隔 | 淺金 | `#E8D5A3` |
| 主文字 | 深墨 | `#2C1810` |
| 次文字 | 棕灰 | `#7A6155` |

**理由**：朱砂紅為台灣宮廟建築最常見的主色，象徵神聖與辟邪。金色常見於神像裝飾與燈籠，作為 accent 可強調重要互動元素。米白模擬宣紙底色，視覺上較灰色更有溫度。

## Risks / Trade-offs

- **Google Fonts 載入速度** → 首次載入需要網路請求；在宮廟環境若網路不穩定，字型可能 fallback 至系統字型。緩解：設定良好的 fallback 字型堆疊（'Noto Serif TC', '楷體', serif）。
- **色彩對比度（Accessibility）** → 朱砂紅底白字需確認符合 WCAG AA 標準（4.5:1）。`#9B2335` 搭配白字對比比約為 7:1，符合標準。
- **原有 Tailwind classes（users/index.html.erb）** → 該頁面混用 Tailwind utility class，部分顏色（如 `bg-green-600` 匯出按鈕）不受 `admin.css` 控制，本次不動這部分，留待日後統一。
