# frozen_string_literal: true

module Telegram
  module Reports
    class SendOrUpdateMessage
      class NoChatId < StandardError; end
      class NoText < StandardError; end

      def call(chat_id:, message_id:, text:, reply_markup: nil)
        raise NoChatId unless chat_id
        raise NoText unless text

        if message_id
          api.edit_message_text(chat_id:, message_id:, text:, reply_markup:, parse_mode: :html)
        else
          api.send_message(chat_id:, text:, reply_markup:, parse_mode: :html)
        end
      rescue Bot::Exceptions::ResponseError => e
        return if e.message.include?('Bad Request: message is not modified:')

        raise e
      end

      private

      def api
        @api ||= TelegramNotifier.client.api
      end
    end
  end
end
