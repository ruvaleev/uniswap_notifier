# frozen_string_literal: true

module Builders
  module Telegram
    module ReplyMarkups
      class PinMessage < Base
        private

        def inline_keyboard(locale)
          [[
            ::Telegram::Bot::Types::InlineKeyboardButton.new(
              text: I18n.t('menu.send_menu', locale:),
              callback_data: 'menu'
            )
          ]]
        end
      end
    end
  end
end
