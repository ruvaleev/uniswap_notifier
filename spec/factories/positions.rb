# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :user
    sequence(:uniswap_id) { |i| i }

    trait :filled do
      transient do
        coin0 { build(:coin) }
        coin1 { build(:coin) }
      end

      status { :active }
      fee { 3000 }
      tick_lower { rand(-270_000..0) }
      tick_upper { rand(1..270_000) }
      liquidity { rand(1_000_000_000_000_000..2_000_000_000_000_000) }
      sequence(:pool_address) { |i| "0xC31E54c9a869B9FcBEcc15363CF510d1c41fa44#{i}" }

      after(:create) do |position, evaluator|
        position.positions_coins = [
          build(:positions_coin, coin: evaluator.coin0, number: 0),
          build(:positions_coin, coin: evaluator.coin1, number: 1)
        ]
      end
    end
  end
end
