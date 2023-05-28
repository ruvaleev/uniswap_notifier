# frozen_string_literal: true

module BlockchainDataFetcher
  class Client
    class << self
      def pool_state(position)
        stub.get_pool_state(
          build_pool_state_request(position, position.positions_coins.includes(:coin))
        )
      end

      def position_data(uniswap_id)
        stub.get_position_data(PositionRequest.new(id: uniswap_id))
      end

      def token_data(address)
        stub.get_token_data(TokenRequest.new(address:))
      end

      private

      def build_pool_state_request(position, positions_coins)
        PoolStateRequest.new(
          poolAddress: position.pool_address,
          chainId: Position::CHAIN_ID,
          token0: build_token_request(positions_coins, '0'),
          token1: build_token_request(positions_coins, '1'),
          fee: position.fee,
          tickLower: position.tick_lower,
          tickUpper: position.tick_upper,
          positionLiquidity: position.liquidity
        )
      end

      def build_token_request(positions_coins, number)
        PoolStateRequest::Token.new(
          **positions_coins.find { |pc| pc.number == number }
            .coin.slice(:address, :decimals, :symbol, :name)
        )
      end

      def stub
        @stub ||=
          BlockchainDataFetcher::Stub.new(
            "#{ENV.fetch('NODE_APP_HOST', 'localhost')}:50051",
            :this_channel_is_insecure
          )
      end
    end
  end
end
