# frozen_string_literal: true

class TelegramNotifier
  @client = Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))

  class << self
    attr_reader :client
  end

  attr_reader :telegram_chat_id, :message

  def initialize(telegram_chat_id, message)
    @telegram_chat_id = telegram_chat_id
    @message = message
  end

  def call
    self.class.client.api.send_message(
      chat_id: telegram_chat_id,
      text: message
    )
  end
end
