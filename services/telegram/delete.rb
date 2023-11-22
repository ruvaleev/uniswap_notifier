# frozen_string_literal: true

module Telegram
  class Delete
    def call(user)
      user.update!(telegram_chat_id: nil)
    end
  end
end
