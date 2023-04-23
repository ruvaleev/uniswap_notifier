# frozen_string_literal: true

class ActualizePricesAndCheckPositionsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    Currency::ActualizePrices.new.call
    CheckPositionsWorker.perform_async
  end
end
