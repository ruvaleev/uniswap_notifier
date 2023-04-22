# frozen_string_literal: true

class TelegramNotifier
  @client = Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))

  class << self
    attr_reader :client
  end

  attr_reader :position

  def initialize(position)
    @position = position
  end

  def call
    self.class.client.api.send_message(
      chat_id: position.user.telegram_chat_id,
      text: needs_rebalancing_message(position)
    )
  end

  private

  def needs_rebalancing_message(position)
    "Your position #{position.from_currency.code}/#{position.to_currency.code} needs rebalancing!"
  end
end
