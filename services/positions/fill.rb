# frozen_string_literal: true

module Positions
  class Fill
    def call(position, additional_params = {})
      position.update!(
        update_params(position).merge(additional_params)
      )
    end

    private

    def update_params(position)
      position_data = BlockchainDataFetcher::Client.position_data(position.uniswap_id)

      {
        positions_coins: positions_coins_attributes(position, position_data),
        fee: position_data.fee,
        tick_lower: position_data.tickLower,
        tick_upper: position_data.tickUpper,
        liquidity: position_data.liquidity,
        pool_address: position_data.poolAddress
      }
    end

    def positions_coins_attributes(position, position_data)
      [
        build_positions_coin(position, position_data.token0, '0'),
        build_positions_coin(position, position_data.token1, '1')
      ]
    end

    def build_positions_coin(position, address, number)
      position.positions_coins.build(coin: find_coin_service.call(address), number:)
    end

    def find_coin_service
      @find_coin_service ||= Coins::FindOrCreate.new
    end
  end
end
