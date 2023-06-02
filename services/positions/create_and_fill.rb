# frozen_string_literal: true

module Positions
  class CreateAndFill
    def call(user, uniswap_id, rebalance_threshold_percents)
      position = user.positions.create!(uniswap_id:, rebalance_threshold_percents:)
      FillWorker.perform_async(position.id)
      position
    end
  end
end
