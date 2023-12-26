# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require_relative 'config/environment'
require 'rollbar/rake_tasks'
require 'sinatra/activerecord/rake'

task :environment do
  Rollbar.configure do |config |
    config.access_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
  end
end
