# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :user
  end
end
