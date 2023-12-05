# frozen_string_literal: true

module Blockchain
  module Arbitrum
    class PoolContract < Base
      ABI_PATH = File.expand_path('./abis/pool_abi.json', __dir__)
      NAME = 'PoolContract'

      def ticks(tick)
        res = client.call(contract, 'ticks', tick)
        Tick.new(res[2], res[3])
      end
    end
  end
end
