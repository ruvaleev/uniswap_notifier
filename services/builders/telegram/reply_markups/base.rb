# frozen_string_literal: true

module Builders
  module Telegram
    module ReplyMarkups
      class Base
        def call(locale)
          ::Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: inline_keyboard(locale))
        end

        private

        def inline_keyboard(*args)
          raise NotImplementedError
        end
      end
    end
  end
end
