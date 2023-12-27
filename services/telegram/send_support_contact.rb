# frozen_string_literal: true

module Telegram
  class SendSupportContact
    def call(chat_id)
      SendMessage.new.call(chat_id:, text: "@#{ENV.fetch('TELEGRAM_SUPPORT_USERNAME', nil)}")
    end
  end
end
