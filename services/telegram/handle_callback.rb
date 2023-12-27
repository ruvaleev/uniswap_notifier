# frozen_string_literal: true

module Telegram
  class HandleCallback
    def call(callback_body)
      if callback_body['callback_query']
        process_callback_query(callback_body['callback_query'])
      elsif callback_body['message'] && callback_body['message']['text']
        process_message(callback_body, callback_body['message']['text'])
      end
    end

    private

    def process_callback_query(callback_query)
      data = callback_query['data']

      return unless data == 'portfolio_report'

      telegram_chat_id = callback_query['message']['chat']['id']
      user = User.find_by(telegram_chat_id:)
      return unless user

      BuildPortfolioReportWorker.perform_async(user.id)
    end

    def process_message(callback_body, text)
      chat_id = callback_body['message']['chat']['id']

      if text.start_with?('/portfolio_report')
        portfolio_report(chat_id)
      elsif text.start_with?('/start')
        start(text.split.last, chat_id)
      elsif text.start_with?('/contact_us')
        contact_us(chat_id)
      end
    end

    def start(token, chat_id)
      user = User.find_by(id: RedisService.client.get(token)) || User.find_by(telegram_chat_id: chat_id)
      return unless user

      user.update(telegram_chat_id: chat_id)
      SendInitialMenuWorker.perform_async(user.id)
    end

    def portfolio_report(telegram_chat_id)
      return unless telegram_chat_id

      user = User.find_by(telegram_chat_id:)
      return unless user

      BuildPortfolioReportWorker.perform_async(user.id)
    end

    def contact_us(chat_id)
      SendSupportContactWorker.perform_async(chat_id)
    end
  end
end
