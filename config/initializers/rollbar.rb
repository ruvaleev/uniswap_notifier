# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
  config.environment = ENV.fetch('SINATRA_ENV', nil)
  config.enabled = ActiveRecord::Type::Boolean.new.cast(ENV.fetch('ROLLBAR_ENABLED', false))
end
