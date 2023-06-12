# frozen_string_literal: true

FactoryBot.define do
  factory :notification_status do
    association :user
    sequence(:uniswap_id) { |i| 100 + i }
  end
end
