# frozen_string_literal: true

module Telegram
  class HandleCallback
    def call(callback_body)
      handle(callback_body, callback_body['message']['text'])
    end

    private

    def handle(callback_body, text)
      return unless text.start_with?('/start')

      start(text.split.last, callback_body['message']['chat']['id'])
    end

    def start(token, chat_id)
      user = User.find_by(id: RedisService.client.get(token))
      return unless user

      user.update(telegram_chat_id: chat_id)
    end
  end
end
