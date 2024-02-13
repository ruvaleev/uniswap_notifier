# frozen_string_literal: true

FactoryBot.define do
  factory :notifications_setting do
    association :user
  end
end
