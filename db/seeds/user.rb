# frozen_string_literal: true

require 'factory_bot_rails'

# rubocop:disable Rails/Output
module Seeds
  module User
    TEST_USER_DATA = {
      name: 'Test User',
      id_card_number: 't123456789',
      password: '1qaz2wsx',
      password_confirmation: '1qaz2wsx',
      status: :member
    }.freeze

    def self.create_all_status_user
      ::User::STATUSES.each_key do |status|
        puts "Creating #{status} user"

        user = FactoryBot.build(:user, status.to_sym)
        user.id_card_number = user.id_card_number.upcase

        next puts "User #{user.id_card_number} already exists" if ::User.exists?(id_card_number: user.id_card_number)

        puts "Created #{status} user" if user.save
      end
    end

    def self.create_test_user
      puts 'Creating Test User'

      user = ::User.new(TEST_USER_DATA)

      return puts 'Test User already exists' if ::User.exists?(id_card_number: user.id_card_number)

      puts 'Created Test User' if user.save
    end
  end
end
# rubocop:enable Rails/Output
