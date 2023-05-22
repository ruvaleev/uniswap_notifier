# frozen_string_literal: true

FactoryBot.define do
  factory :coin do
    address { SecureRandom.hex }
    symbol { SecureRandom.hex(2) }
    decimals { rand(4..20) }
    name { SecureRandom.hex }
  end
end
