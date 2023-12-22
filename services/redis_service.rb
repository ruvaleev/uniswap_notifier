# frozen_string_literal: true

class RedisService
  class << self
    def client
      @client ||= Redis.new(url: ENV.fetch('REDIS_URL', nil))
    end

    def fetch(key)
      value = client.get(key)

      if value.nil?
        value = yield
        client.set(key, value)
      end
      value
    end
  end
end
