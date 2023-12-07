# frozen_string_literal: true

FactoryBot.define do
  factory :position, class: 'Reports::Position' do
    association :portfolio_report
  end
end
