# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :user
    association :coin0, factory: :coin
    association :coin1, factory: :coin
  end
end
