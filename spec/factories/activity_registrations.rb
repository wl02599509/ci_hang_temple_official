FactoryBot.define do
  factory :activity_registration do
    activity
    user
    status { :pending }
    payment_method { nil }
    collector { nil }
    paid_at { nil }
    cancel_reason { nil }
    cancelled_at { nil }
    refund_amount { nil }
    refunded_at { nil }

    trait :paid do
      status { :paid }
      payment_method { :cash }
      collector { Faker::Name.name }
      paid_at { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
      cancel_reason { Faker::Lorem.sentence }
      cancelled_at { Time.current }
    end

    trait :cancelled_with_refund do
      status { :cancelled }
      cancel_reason { Faker::Lorem.sentence }
      cancelled_at { Time.current }
      refund_amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
      refunded_at { Time.current }
    end
  end
end
