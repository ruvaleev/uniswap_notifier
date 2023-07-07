# frozen_string_literal: true

module Telegram
  class CreateLink
    TIMEOUT_SECONDS = 600

    def call(user_id)
      token = SecureRandom.hex
      save_in_cache(token, user_id)
      link(token)
    end

    private

    def save_in_cache(token, user_id)
      RedisService.client.set(token, user_id, ex: TIMEOUT_SECONDS)
    end

    def link(token)
      "https://t.me/#{ENV.fetch('TG_BOT_USERNAME', nil)}?start=#{token}"
    end
  end
end
