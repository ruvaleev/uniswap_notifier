# frozen_string_literal: true

class SendSupportContactWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(chat_id)
    Telegram::SendSupportContact.new.call(chat_id)
  end
end
