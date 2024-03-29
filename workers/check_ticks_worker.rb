# frozen_string_literal: true

class CheckTicksWorker
  include Sidekiq::Worker

  DEFAULT_THRESHOLD = 0

  def perform
    Wallet.joins(:user).where.not(users: { telegram_chat_id: nil }).select(:address).each_slice(1000) do |batch|
      Sidekiq::Client.push_bulk(
        'class' => CheckByOwnerAddressWorker,
        'args' => batch.map { |payload| [payload[:address], DEFAULT_THRESHOLD] }
      )
    end
  end
end
