# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    association :user
    sequence(:address) { |i| rand_blockchain_address(i) }
  end
end
