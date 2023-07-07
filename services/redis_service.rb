# frozen_string_literal: true

class RedisService
  class << self
    def client
      @client ||= Redis.new(url: ENV.fetch('REDIS_URL', nil))
    end
  end
end
