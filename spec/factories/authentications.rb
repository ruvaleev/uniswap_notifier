# frozen_string_literal: true

FactoryBot.define do
  factory :authentication do
    association :user
    sequence(:ip_address) { |i| "123.45.67.#{i}" }
    token { SecureRandom.hex }
  end
end
