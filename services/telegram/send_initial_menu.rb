# frozen_string_literal: true

module Telegram
  class SendInitialMenu
    def call(user_id)
      user = User.find(user_id)
      return unless user.telegram_chat_id

      message_id = send_message(user.telegram_chat_id, user.locale)
      pin_message(user.telegram_chat_id, message_id)
      user.update(menu_message_id: message_id)
    end

    private

    def send_message(chat_id, locale)
      SendMessage.new.call(
        chat_id:,
        text: I18n.t('initial_menu.text'),
        reply_markup: reply_markup(locale)
      )
    end

    def pin_message(chat_id, message_id)
      api.pin_chat_message(chat_id:, message_id:)
    end

    def api
      @api ||= TelegramNotifier.client.api
    end

    def reply_markup(locale)
      Builders::Telegram::ReplyMarkups::PinMessage.new.call(locale)
    end
  end
end
