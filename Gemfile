# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bcrypt'
gem 'httparty'
gem 'pg'
gem 'rake'
gem 'require_all'
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
