# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:address) { |i| "#{SecureRandom.hex}#{i}" }
  end
end
