# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activesupport', '>= 7.0.7.1'
gem 'bcrypt'
gem 'bundle-audit'
gem 'dotenv'
gem 'eth'
gem 'google-protobuf'
gem 'grpc', '~> 1.55'
gem 'grpc-tools'
gem 'httparty', '>= 0.21.0'
gem 'i18n'
gem 'pg'
gem 'puma', '>= 6.3.1'
gem 'rake'
gem 'redis'
gem 'require_all'
gem 'sidekiq', '>= 7.1.3'
gem 'sidekiq-scheduler'
gem 'sinatra', require: false
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
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-sqlimit'
  gem 'securerandom'
  gem 'shoulda-matchers'
  gem 'webmock'
end
