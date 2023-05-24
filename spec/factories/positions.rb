# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :user
    sequence(:uniswap_id) { |i| i }
  end
end
