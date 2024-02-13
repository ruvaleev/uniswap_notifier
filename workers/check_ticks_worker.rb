# frozen_string_literal: true

class CheckTicksWorker
  include Sidekiq::Worker

  DEFAULT_THRESHOLD = 0

  def perform
    Wallet.joins(:user)
          .includes(user: :notifications_setting)
          .where(notifications_settings: { out_of_range: [nil, true] })
          .where.not(users: { telegram_chat_id: nil }).select(:address, :user_id).each_slice(1000) do |batch|
      Sidekiq::Client.push_bulk(
        'class' => CheckByOwnerAddressWorker,
        'args' => batch.map { |payload| [payload[:address], DEFAULT_THRESHOLD] }
      )
    end
  end
end
