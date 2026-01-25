require 'taiwanese_id_validator/twid_generator'

FactoryBot.define do
  factory :user do
    id_number { TwidGenerator.generate }
    name { Faker::Name.name }
    phone_number { "09#{Faker::Number.number(digits: 8)}" }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 80) }
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    status { :normal }

    trait :male do
      TwidGenerator.generate("male")
    end

    trait :female do
      TwidGenerator.generate("female")
    end

    # 不同身份的使用者
    trait :master do
      status { :master }
    end

    trait :vice_master do
      status { :vice_master }
    end

    trait :president do
      status { :president }
    end

    trait :member do
      status { :member }
    end

    trait :volunteer do
      status { :volunteer }
    end

    # 有生肖的使用者
    trait :with_zodiac do
      zodiac { User.zodiacs.keys.sample }
    end

    # 沒有 email 的使用者
    trait :without_email do
      email { nil }
    end
  end
end
