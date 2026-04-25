FactoryBot.define do
  factory :activity do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    notes { nil }
    event_date { Date.today + 30 }
    registration_start_date { Date.today + 7 }
    registration_end_date { Date.today + 14 }
    fee { "500.00" }
    status { :draft }

    trait :published do
      status { :published }
    end

    trait :with_notes do
      notes { Faker::Lorem.sentence }
    end
  end
end
