# frozen_string_literal: true

module Telegram
  module Reports
    class SendOrUpdateMessage
      class NoChatId < StandardError; end
      class NoText < StandardError; end

      def call(chat_id:, message_id:, text:)
        raise NoChatId unless chat_id
        raise NoText unless text

        if message_id
          TelegramNotifier.client.api.edit_message_text(chat_id:, message_id:, text:, parse_mode: :html)
        else
          TelegramNotifier.client.api.send_message(chat_id:, text:, parse_mode: :html)
        end
      end
    end
  end
end
