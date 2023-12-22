# frozen_string_literal: true

RSpec.configure do |config|
  config.after do
    Redis.new.flushdb
  end
end
