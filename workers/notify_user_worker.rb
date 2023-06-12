# frozen_string_literal: true

class NotifyUserWorker
  include Sidekiq::Worker

  def perform(position_id)
    position = Position.find(position_id)
    return if position.notified?

    TelegramNotifier.new(position.user.telegram_chat_id, position.uniswap_id).call
  end
end
