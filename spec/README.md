# RSpec 測試指南

## 運行測試

```bash
# 運行所有測試
bundle exec rspec

# 運行特定文件
bundle exec rspec spec/models/user_spec.rb

# 運行特定測試（依行號）
bundle exec rspec spec/models/user_spec.rb:10

# 運行特定目錄下的所有測試
bundle exec rspec spec/models/
```

## 已安裝的測試套件

### 核心套件
- **rspec-rails** - Rails 的 RSpec 測試框架
- **factory_bot_rails** - 測試資料工廠，用於建立測試數據
- **faker** - 產生假資料的工具

### 輔助工具
- **simplecov** - 程式碼覆蓋率分析工具
- **shoulda-matchers** - 提供簡潔的 matcher 語法
- **database_cleaner-active_record** - 在測試之間清理資料庫

## 目錄結構

```
spec/
├── factories/          # FactoryBot 工廠定義
├── models/            # Model 測試
├── controllers/       # Controller 測試
├── requests/          # Request 測試（整合測試）
├── helpers/           # Helper 測試
├── mailers/           # Mailer 測試
├── jobs/              # Job 測試
├── features/          # Feature 測試
├── support/           # 支援文件和共用配置
├── spec_helper.rb     # RSpec 基本配置
└── rails_helper.rb    # Rails 專用配置
```

## 使用範例

### 建立 Factory

在 `spec/factories/` 目錄下建立檔案：

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
```

### 使用 Factory

```ruby
# 建立資料（不存入資料庫）
user = build(:user)

# 建立並存入資料庫
user = create(:user)

# 覆寫屬性
user = create(:user, name: "特定名稱")
```

### Model 測試範例

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:posts) }
  end

  describe '#full_name' do
    it 'returns the full name' do
      user = create(:user, name: 'John Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

### Request 測試範例

```ruby
# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    it 'returns success status' do
      get users_path
      expect(response).to have_http_status(:success)
    end
  end
end
```

## 程式碼覆蓋率

執行測試後，程式碼覆蓋率報告會自動生成在 `coverage/` 目錄下。
開啟 `coverage/index.html` 即可查看詳細的覆蓋率報告。

## RuboCop 整合

已安裝 `rubocop-rspec` 來檢查測試程式碼的風格。執行：

```bash
bundle exec rubocop spec/
```
