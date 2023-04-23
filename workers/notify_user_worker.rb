# frozen_string_literal: true

# require 'sidekiq-scheduler'

class NotifyUserWorker
  include Sidekiq::Worker

  def perform(position_id)
    TelegramNotifier.new(
      Position.find(position_id)
    ).call
  end
end
