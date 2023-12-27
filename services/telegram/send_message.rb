# frozen_string_literal: true

module Telegram
  class SendMessage
    class NoChatId < StandardError; end
    class NoText < StandardError; end

    def call(chat_id:, text:, reply_markup: nil)
      msg = TelegramNotifier.client.api.send_message(chat_id:, text:, reply_markup:, parse_mode: :html)
      msg['result']['message_id']
    end
  end
end
