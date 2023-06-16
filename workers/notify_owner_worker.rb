# frozen_string_literal: true

class NotifyOwnerWorker
  include Sidekiq::Worker

  def perform(address, uniswap_id)
    user = User.find_by(address:)
    chat_id = user.telegram_chat_id
    notification_status = user.notification_statuses.find_or_initialize_by(uniswap_id:)
    return if notification_status.notified?

    TelegramNotifier.new(chat_id, uniswap_id).call
    notification_status.notified!
  end
end
