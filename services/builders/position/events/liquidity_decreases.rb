# frozen_string_literal: true

require_relative 'liquidity_increases'

module Builders
  module Position
    module Events
      class LiquidityDecreases < LiquidityIncreases
        EVENT_NAME = 'DecreaseLiquidity'
      end
    end
  end
end
