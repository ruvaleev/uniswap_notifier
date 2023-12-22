# frozen_string_literal: true

class NotifyOwnerWorker
  include Sidekiq::Worker

  NOTIFICATION_TIMEOUT_SECONDS = 300

  def perform(address, uniswap_id, message_type)
    wallet = Wallet.joins(:user).find_by(address:)
    user = wallet.user
    chat_id = user.telegram_chat_id
    notification_status = user.notification_statuses.find_or_initialize_by(uniswap_id:)
    return if notification_status.status == message_type || already_sent?(notification_status)

    TelegramNotifier.new(chat_id, message(uniswap_id, message_type)).call
    notification_status.update(status: message_type, last_sent_at: Time.now)
  end

  private

  def already_sent?(notification_status)
    notification_status.last_sent_at.present? &&
      notification_status.last_sent_at >= (Time.now - NOTIFICATION_TIMEOUT_SECONDS)
  end

  def message(uniswap_id, message_type)
    if message_type == 'in_range'
      "Your position is IN RANGE: https://app.uniswap.org/#/pools/#{uniswap_id}"
    else
      "Your position is OUT OF RANGE (needs rebalancing): https://app.uniswap.org/#/pools/#{uniswap_id}"
    end
  end
end
