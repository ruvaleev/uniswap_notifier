# frozen_string_literal: true

class SendMenuWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(chat_id)
    Telegram::SendMenu.new.call(chat_id)
  end
end
