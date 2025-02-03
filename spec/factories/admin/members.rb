FactoryBot.define do
  factory :admin_member, class: 'Admin::Member' do
    sequence(:name) { |n| "會員#{n}" }
    sequence(:id_card_number) { |n| "A1#{n.to_s.rjust(8, '0')}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    permission { 'member' }
  end

  trait :male do
    id_card_number { "A1#{n.to_s.rjust(8, '0')}" }
  end

  trait :female do
    id_card_number { "A2#{n.to_s.rjust(8, '0')}" }
  end
end
