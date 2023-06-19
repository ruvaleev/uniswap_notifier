# frozen_string_literal: true

class CheckByOwnerAddressWorker
  include Sidekiq::Worker

  def perform(address, threshold)
    Positions::CheckByOwnerAddress.new(address, threshold).call
  end
end
