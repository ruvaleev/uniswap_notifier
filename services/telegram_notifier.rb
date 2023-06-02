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
    return if position.notified?

    self.class.client.api.send_message(
      chat_id: position.user.telegram_chat_id,
      text: needs_rebalancing_message(position)
    )
    position.notified!
  end

  private

  def needs_rebalancing_message(position)
    "Your position needs rebalancing: https://app.uniswap.org/#/pools/#{position.uniswap_id}"
  end
end
