# frozen_string_literal: true

FactoryBot.define do
  factory :position_report_build do
    association :portfolio_report_build
    sequence(:message_id) { |i| i }
  end
end
