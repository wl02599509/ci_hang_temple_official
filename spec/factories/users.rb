# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'User' do
    sequence(:name) { |n| "會員#{n}" }
    sequence(:id_card_number) { |n| "#{('a'..'z').to_a.sample}1#{n.to_s.rjust(8, '0')}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    status { 'general' }
  end

  trait :male do
    id_card_number { "#{('a'..'z').to_a.sample}1#{n.to_s.rjust(8, '0')}" }
  end

  trait :female do
    id_card_number { "#{('a'..'z').to_a.sample}2#{n.to_s.rjust(8, '0')}" }
  end

  User::STATUSES.each do |key, value|
    trait key do
      status { value }
    end
  end
end
