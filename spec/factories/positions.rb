# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :user
    association :from_currency, factory: :currency
    association :to_currency, factory: :currency
    max_price { rand(1..100) }
    min_price { rand(101..200) }
  end
end
