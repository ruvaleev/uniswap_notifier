# frozen_string_literal: true

module Builders
  module Position
    module Events
      class LiquidityIncreases < Base
        EVENT_NAME = 'IncreaseLiquidity'

        private

        def result_message(log, token_0, token_1, timestamp, date)
          super(log, token_0, token_1, timestamp, date).merge(liquidity: log['liquidity'])
        end
      end
    end
  end
end
