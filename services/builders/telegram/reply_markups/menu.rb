# frozen_string_literal: true

module Builders
  module Telegram
    module ReplyMarkups
      class Menu < Base
        private

        def inline_keyboard(locale)
          [[
            ::Telegram::Bot::Types::InlineKeyboardButton.new(
              text: I18n.t('menu.portfolio_report', locale:),
              callback_data: 'portfolio_report'
            ),
            ::Telegram::Bot::Types::InlineKeyboardButton.new(
              text: I18n.t('menu.contact_us'),
              url: "https://t.me/#{ENV.fetch('TELEGRAM_SUPPORT_USERNAME', nil)}"
            )
          ]]
        end
      end
    end
  end
end
