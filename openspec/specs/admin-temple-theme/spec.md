# admin-temple-theme Specification

## Purpose

TBD - created by archiving change 'temple-admin-theme'. Update Purpose after archive.

## Requirements

### Requirement: 後台主色調使用宮廟配色

後台管理介面 SHALL 使用朱砂紅（`#9B2335`）作為主色調，取代原有藍紫漸層配色。Header、Sidebar active 狀態、Primary 按鈕皆使用此色系。

#### Scenario: Header 顯示宮廟主色

- **WHEN** 使用者進入後台任何頁面
- **THEN** 頂部 Header 背景 SHALL 顯示朱砂紅漸層（`#9B2335` → `#6B1C2A`），而非藍紫漸層

#### Scenario: Sidebar active 項目顯示宮廟配色

- **WHEN** 使用者目前所在頁面對應的 Sidebar 項目為 active
- **THEN** active 項目背景 SHALL 使用朱砂紅，並在左側顯示金色（`#C9A14A`）邊框

#### Scenario: Primary 按鈕使用朱砂紅

- **WHEN** 頁面上出現 `.btn-primary` 按鈕
- **THEN** 按鈕背景 SHALL 為朱砂紅，hover 時加深顏色


<!-- @trace
source: temple-admin-theme
updated: 2026-04-19
code:
  - .spectra.yaml
  - CLAUDE.md
-->

---
### Requirement: 後台背景使用米白色系

後台整體背景 SHALL 使用米白色（`#FAF7F2`），取代原有冷灰色（`#f5f6fa`），以提升視覺溫暖感。

#### Scenario: 頁面背景呈現米白

- **WHEN** 使用者進入後台任何頁面
- **THEN** `.admin-container` 背景 SHALL 為 `#FAF7F2`


<!-- @trace
source: temple-admin-theme
updated: 2026-04-19
code:
  - .spectra.yaml
  - CLAUDE.md
-->

---
### Requirement: 後台邊框與分隔線使用淺金色

表單、卡片、分隔線等邊框元素 SHALL 使用淺金色（`#E8D5A3`），取代原有的淺灰色（`#e2e8f0`）。

#### Scenario: 表單 input 邊框顯示淺金色

- **WHEN** 使用者看到 `.form-control` 輸入欄位（未 focus 狀態）
- **THEN** 輸入欄位邊框 SHALL 為淺金色 `#E8D5A3`

#### Scenario: 表單 input focus 顯示金色

- **WHEN** 使用者點擊 `.form-control` 輸入欄位進行 focus
- **THEN** 邊框 SHALL 變為金色 `#C9A14A`，並顯示金色 focus ring


<!-- @trace
source: temple-admin-theme
updated: 2026-04-19
code:
  - .spectra.yaml
  - CLAUDE.md
-->

---
### Requirement: 後台標題使用 Noto Serif TC 字型

後台所有標題（h1、h2）SHALL 使用 Noto Serif TC 字型，提供接近楷書的視覺感受，增添文化氣質。

#### Scenario: 頁面載入時標題使用 Serif 字型

- **WHEN** 後台頁面完成載入
- **THEN** `.admin-header h1`、`.content-header h2` 等標題元素 SHALL 以 Noto Serif TC 顯示


<!-- @trace
source: temple-admin-theme
updated: 2026-04-19
code:
  - .spectra.yaml
  - CLAUDE.md
-->

---
### Requirement: 後台內文使用 Noto Sans TC 字型

後台一般內文、表格、按鈕等 SHALL 使用 Noto Sans TC 字型，確保繁體中文的清晰閱讀性，對年長使用者友善。

#### Scenario: 頁面內文以 Sans 字型顯示

- **WHEN** 後台頁面完成載入
- **THEN** `.admin-container` 內的一般文字 SHALL 以 Noto Sans TC 顯示，而非英文優先的 system font

<!-- @trace
source: temple-admin-theme
updated: 2026-04-19
code:
  - .spectra.yaml
  - CLAUDE.md
-->