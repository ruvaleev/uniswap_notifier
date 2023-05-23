# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bcrypt'
gem 'bundle-audit'
gem 'google-protobuf'
gem 'grpc'
gem 'grpc-tools'
gem 'httparty', '>= 0.21.0'
gem 'pg'
gem 'rake'
gem 'redis'
gem 'require_all'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sinatra-activerecord'
gem 'strong_migrations'
gem 'telegram-bot-ruby'

group :development do
  gem 'database_consistency', require: false
  gem 'rubocop'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot'
  gem 'rspec'
  gem 'rspec-sqlimit'
  gem 'securerandom'
  gem 'shoulda-matchers'
  gem 'webmock'
end
