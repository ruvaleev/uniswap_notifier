# frozen_string_literal: true

source 'https://rubygems.org'

gem 'httparty'
gem 'pg'
gem 'rake'
gem 'require_all'
gem 'sinatra-activerecord'
gem 'strong_migrations'

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
  gem 'rspec'
  gem 'shoulda-matchers'
  gem 'webmock'
end
