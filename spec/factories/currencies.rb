# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    sequence(:code) { |i| "#{SecureRandom.hex(2).upcase}#{i}" }
    usd_price { rand(0.1..1000) }
  end
end
