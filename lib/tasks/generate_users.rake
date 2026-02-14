require "taiwanese_id_validator/twid_generator"

namespace :dev do
  desc "產生涵蓋所有 status 和 zodiac 的測試用 user 資料（可選參數：reset=true 先刪除所有使用者）"
  task generate_users: :environment do
    def create_test_user(status:, all_zodiacs: [])
      zodiac_value = [ all_zodiacs.sample, nil ].sample
      email_value = [ Faker::Internet.email, nil ].sample

      User.create!(
        id_number: TwidGenerator.generate,
        name: Faker::Name.name,
        phone_number: "09#{Faker::Number.number(digits: 8)}",
        birth_date: Faker::Date.birthday(min_age: 18, max_age: 80),
        address: Faker::Address.full_address,
        email: email_value,
        password: "password123",
        password_confirmation: "password123",
        status: status,
        zodiac: zodiac_value
      )
    rescue ActiveRecord::RecordInvalid => e
      puts "建立失敗: #{e.record.errors.full_messages.join(', ')}"
      raise
    end

    if ENV["reset"] == "true"
      user_count = User.count
      User.destroy_all
      puts "已刪除 #{user_count} 位使用者"
    end

    puts "開始產生測試用 user 資料..."

    all_statuses = User.statuses.keys
    all_zodiacs = User.zodiacs.keys

    unique_statuses = [ "master", "vice_master" ]
    other_statuses = all_statuses - unique_statuses
    created_count = 0

    unique_statuses.each do |status|
      next if User.find_by(status:)

      user = create_test_user(status: status, all_zodiacs: all_zodiacs)
      created_count += 1
      puts "✓ 建立 #{status} 使用者: #{user.name} (生肖: #{user.zodiac || '無'}) [唯一]"
    end

    other_statuses.each do |status|
      user = create_test_user(status: status, all_zodiacs: all_zodiacs)
      created_count += 1
      puts "✓ 建立 #{status} 使用者: #{user.name} (生肖: #{user.zodiac || '無'})"
    end

    puts "\n完成！共建立 #{created_count} 位使用者"
    puts "密碼統一為: password123"
    puts "\n特別說明："
    puts "- master 和 vice_master 各只有一位使用者"
    puts "- 使用 reset=true 參數可先刪除所有使用者再建立新資料"
  end
end
