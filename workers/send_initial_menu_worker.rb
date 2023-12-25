# frozen_string_literal: true

class SendInitialMenuWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(user_id)
    Telegram::SendInitialMenu.new.call(user_id)
  end
end
