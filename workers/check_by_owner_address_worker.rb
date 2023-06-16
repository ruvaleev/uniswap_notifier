# frozen_string_literal: true

class CheckByOwnerAddressWorker
  include Sidekiq::Worker

  def perform(address, threshold)
    Positions::CheckByOwnerAddress.new.call(address, threshold)
  end
end
