## Why

目前後台管理系統的視覺風格採用藍紫色漸層，屬於通用的科技/SaaS 風格，與慈航宮的宮廟文化完全不符。後台使用者除了 IT 開發者之外，還包含宮主與幹部等年長成員，需要一個視覺上貼近宮廟文化、且易於辨識的介面。

## What Changes

- 將後台主色調從藍紫色（#667eea / #764ba2）替換為朱砂紅（#9B2335）與深紅褐（#6B1C2A）
- 加入金色（#C9A14A）作為 accent 色，用於 active 狀態、hover、重點標示
- 整體背景色從冷灰（#f5f6fa）換為米白（#FAF7F2），降低視覺疲勞
- 邊框與分隔線改用淺金色（#E8D5A3），增添宮廟溫暖感
- 字型堆疊加入 Noto Serif TC（標題）與 Noto Sans TC（內文），提升中文閱讀體驗與文化氣質
- 於 admin layout head 引入 Google Fonts 的 Noto Serif TC / Noto Sans TC

## Capabilities

### New Capabilities

- `admin-temple-theme`: 後台宮廟主題樣式系統，包含色彩設計規範與字型設定

### Modified Capabilities

（無現有 spec 需要修改）

## Impact

- `app/assets/stylesheets/admin.css`：主要改動檔案，替換色彩系統與字型設定
- `app/views/layouts/admin/application.html.erb`：加入 Google Fonts 引入標籤
- 不影響任何 Rails 功能邏輯、路由、資料庫或 API
- 不影響前台樣式（application.tailwind.css 不動）
