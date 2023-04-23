# frozen_string_literal: true

class ActualizePricesAndCheckPositionsWorker
  include Sidekiq::Worker

  def perform
    Currency::ActualizePrices.new.call
    CheckPositionsWorker.perform_async
  end
end
