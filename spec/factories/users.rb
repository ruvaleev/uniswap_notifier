# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:address) { |i| "#{SecureRandom.hex}#{i}" }
    sequence(:login) { |i| "#{SecureRandom.hex}#{i}" }
    password_hash { SecureRandom.hex }
  end
end
