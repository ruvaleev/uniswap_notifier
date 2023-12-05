# frozen_string_literal: true

module Blockchain
  module Arbitrum
    class Base
      attr_reader :abi, :client, :contract

      RPC_ENDPOINT = ENV.fetch('ARBITRUM_URL', nil)

      def initialize(address)
        file = File.read(self.class::ABI_PATH)
        @abi = JSON.parse(file)
        @contract = Eth::Contract.from_abi(name: self.class::NAME, address:, abi:)
        @client = Eth::Client.create(RPC_ENDPOINT)
      end
    end
  end
end
