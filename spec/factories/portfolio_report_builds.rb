# frozen_string_literal: true

FactoryBot.define do
  factory :portfolio_report_build do
    association :user
    sequence(:initial_message_id) { |i| i }
  end
end
