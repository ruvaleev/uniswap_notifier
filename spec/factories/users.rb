# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:login) { |i| "#{SecureRandom.hex}#{i}" }
    password_hash { SecureRandom.hex }
  end
end
