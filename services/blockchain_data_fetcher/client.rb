# frozen_string_literal: true

module BlockchainDataFetcher
  class Client
    class << self
      def position_data(uniswap_id)
        stub.get_position_data(PositionRequest.new(id: uniswap_id))
      end

      def token_data(address)
        stub.get_token_data(TokenRequest.new(address:))
      end

      private

      def stub
        @stub ||= BlockchainDataFetcher::Stub.new('localhost:50051', :this_channel_is_insecure)
      end
    end
  end
end
