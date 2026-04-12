## 1. 引入 Google Fonts 字型

- [x] 1.1 在 `app/views/layouts/admin/application.html.erb` 的 `<head>` 加入 Google Fonts CDN link（Noto Serif TC 400/600、Noto Sans TC 400/500）

## 2. 更新 admin.css 字型設定

- [x] 2.1 將 `.admin-container` 的 `font-family` 換為 `'Noto Sans TC', sans-serif`
- [x] 2.2 為 `.admin-header h1`、`.content-header h2`、`.content-header h3` 加入 `font-family: 'Noto Serif TC', serif`

## 3. 替換主色調為宮廟配色

- [x] 3.1 將 `.admin-header` 的 `background` 漸層從藍紫（`#667eea → #764ba2`）改為朱砂紅（`#9B2335 → #6B1C2A`）
- [x] 3.2 將 `.sidebar-nav li.active a` 的 `background` 漸層改為朱砂紅，`border-right` 顏色改為金色 `#C9A14A`
- [x] 3.3 將 `.sidebar-nav a:hover` 的 `color` 從 `#667eea` 改為 `#9B2335`
- [x] 3.4 將 `.btn-primary` 的 `background` 漸層從藍紫改為朱砂紅（`#9B2335 → #6B1C2A`）
- [x] 3.5 將 `.btn-primary:hover` 的 `box-shadow` 顏色從藍紫改為朱砂紅 rgba
- [x] 3.6 將 `.btn-login` 的 `color` 從 `#667eea` 改為 `#9B2335`
- [x] 3.7 將 `.login-footer a` 的 `color` 從 `#667eea` 改為 `#9B2335`，`hover` 顏色從 `#764ba2` 改為 `#6B1C2A`
- [x] 3.8 將 `.stat-icon` 的 `background` 漸層從藍紫改為朱砂紅

## 4. 替換背景與邊框色彩

- [x] 4.1 將 `.admin-container` 的 `background-color` 從 `#f5f6fa` 改為米白 `#FAF7F2`
- [x] 4.2 將 `.form-control` 的 `border-color` 從 `#e2e8f0` 改為淺金 `#E8D5A3`
- [x] 4.3 將 `.form-control:focus` 的 `border-color` 從 `#667eea` 改為金色 `#C9A14A`，`box-shadow` 顏色改為金色 rgba
- [x] 4.4 將 `.login-footer` 的 `border-top` 顏色從 `#e2e8f0` 改為淺金 `#E8D5A3`
- [x] 4.5 將 `.login-card` 等卡片的 `box-shadow` 顏色調整為帶暖色調

## 5. 驗證

- [ ] 5.1 啟動 `bin/dev`，確認 Header、Sidebar active、按鈕均顯示朱砂紅
- [ ] 5.2 確認 Dashboard 頁面背景為米白，標題為 Noto Serif TC
- [ ] 5.3 確認登入頁面（`/admin/users/sign_in`）表單邊框為淺金色，focus 顯示金色
- [ ] 5.4 確認 Sidebar hover 顏色為朱砂紅
