# frozen_string_literal: true

module Positions
  class UpdatePoolState
    def call(position)
      pool_state = BlockchainDataFetcher::Client.pool_state(position)
      update_positions_coin(position, pool_state.token0, 0)
      update_positions_coin(position, pool_state.token1, 1)
    end

    private

    def update_positions_coin(position, token_data, number)
      positions_coin = position.positions_coins.find_by(number:)

      positions_coin.update(
        positions_coin_param(token_data)
      )
    end

    def positions_coin_param(token_data)
      {
        amount: token_data.amount,
        price: token_data.price,
        min_price: token_data.minPrice,
        max_price: token_data.maxPrice
      }
    end
  end
end
