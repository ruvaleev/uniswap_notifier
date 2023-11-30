# frozen_string_literal: true

module Blockchain
  module Arbitrum
    class PoolContract
      attr_reader :client, :contract

      ABI_PATH = File.expand_path('./abis/pool_abi.json', __dir__)
      NAME = 'PoolContract'

      def initialize(address)
        file = File.read(ABI_PATH)
        abi = JSON.parse(file)
        @contract = Eth::Contract.from_abi(name: NAME, address:, abi:)
        @client = Eth::Client.create(RPC_ENDPOINT)
      end

      def ticks(tick)
        res = client.call(contract, 'ticks', tick)
        Tick.new(res[2], res[3])
      end
    end
  end
end
