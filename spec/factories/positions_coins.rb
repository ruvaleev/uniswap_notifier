# frozen_string_literal: true

FactoryBot.define do
  factory :positions_coin do
    association :coin
    association :position
  end
end
