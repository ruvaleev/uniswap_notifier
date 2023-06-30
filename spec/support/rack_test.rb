# frozen_string_literal: true

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
