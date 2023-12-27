# frozen_string_literal: true

module Telegram
  class SendMenu
    def call(chat_id)
      user = User.find_by(telegram_chat_id: chat_id)
      return unless user

      reply_markup = Builders::Telegram::ReplyMarkups::Menu.new.call(user.locale)

      SendMessage.new.call(chat_id:, text: I18n.t('menu.choose_action'), reply_markup:)
    end
  end
end
