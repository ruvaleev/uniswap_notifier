# frozen_string_literal: true

FactoryBot.define do
  factory :portfolio_report do
    association :user
    sequence(:initial_message_id) { |i| i }
    prices { { 'ARB' => 1.17, 'WETH' => 2000 } }
  end
end
