# frozen_string_literal: true

FactoryBot.define do
  factory :positions_coin do
    association :coin
    association :position
    amount { rand(1000) }
    price { [rand(0..0.1), rand(2000)].sample }
    min_price { price - (price * 0.2) }
    max_price { price + (price * 0.2) }
  end
end
