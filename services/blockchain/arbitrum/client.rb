# frozen_string_literal: true

module Blockchain
  module Arbitrum
    class Client < Base
      class << self
        def block_timestamp(block_number)
          cache_key = "timestamp_of_#{block_number}"
          RedisService.fetch(cache_key) do
            block = client.eth_get_block_by_number(block_number, false)
            block['result']['timestamp'].to_i(16)
          end.to_i
        end

        private

        def client
          @client ||= Eth::Client.create(self::RPC_ENDPOINT)
        end
      end
    end
  end
end
