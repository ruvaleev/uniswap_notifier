# frozen_string_literal: true

class TelegramNotifier
  @client = Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))

  class << self
    attr_reader :client
  end

  attr_reader :telegram_chat_id, :uniswap_id

  def initialize(telegram_chat_id, uniswap_id)
    @telegram_chat_id = telegram_chat_id
    @uniswap_id = uniswap_id
  end

  def call
    self.class.client.api.send_message(
      chat_id: telegram_chat_id,
      text: needs_rebalancing_message(uniswap_id)
    )
  end

  private

  def needs_rebalancing_message(uniswap_id)
    "Your position needs rebalancing: https://app.uniswap.org/#/pools/#{uniswap_id}"
  end
end
