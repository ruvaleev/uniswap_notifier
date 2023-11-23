# frozen_string_literal: true

module Telegram
  BOT_URL = "https://t.me/#{ENV.fetch('TG_BOT_USERNAME', nil)}".freeze

  class Check
    def call(user)
      is_connected = user.telegram_chat_id.present?

      { connected: is_connected, link: (BOT_URL if is_connected) }
    end
  end
end
