# frozen_string_literal: true

FactoryBot.define do
  factory :positions_coin do
    association :coin
    association :position
    amount { rand(1000) }
    price { [rand(0..0.1), rand(2000)].sample }
    min_price { price - (price * 0.2) }
    max_price { price + (price * 0.2) }

    trait :to_rebalance do
      min_price { price }
    end

    trait :balanced do
      min_price { rand(0..0.1) }
      max_price { rand(1..2000) }
      price { [min_price, max_price].sum / 2 }
    end
  end
end
