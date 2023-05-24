# frozen_string_literal: true

module Positions
  class CreateAndFill
    def call(user, uniswap_id)
      position = user.positions.create!(uniswap_id:)
      FillWorker.perform_async(position.id)
      position
    end
  end
end
