# frozen_string_literal: true

module Positions
  class CalculateAmounts
    Q96 = BigDecimal(2)**96

    attr_reader :current_sqrt_price, :current_tick, :liquidity,
                :position, :sqrt_ratio_lower, :sqrt_ratio_upper

    def initialize(position)
      @liquidity = position.liquidity
      @current_sqrt_price = BigDecimal(position.pool['sqrtPrice']) / Q96
      @current_tick = tick_at_sqrt_price(@current_sqrt_price)
      @position = position
      @sqrt_ratio_lower = sqrt_ratio_at_tick(position.tick_lower)
      @sqrt_ratio_upper = sqrt_ratio_at_tick(position.tick_upper)
    end

    def call
      amount_0_in_decimals, amount_1_in_decimals =
        calculate_amounts_in_decimals(position.tick_lower, position.tick_upper)

      {
        amount_0: amount_0_in_decimals / position.divider_0,
        amount_1: amount_1_in_decimals / position.divider_1
      }
    end

    private

    def tick_at_sqrt_price(sqrt_price)
      (Math.log(sqrt_price**2) / Math.log(1.0001)).floor
    end

    def sqrt_ratio_at_tick(tick)
      BigDecimal(Math.sqrt(1.0001**tick).to_s)
    end

    def calculate_amounts_in_decimals(tick_lower, tick_upper)
      if current_tick < tick_lower
        [calculate_amount_0(sqrt_ratio_lower), 0]
      elsif current_tick >= tick_upper
        [0, calculate_amount_1(sqrt_ratio_upper)]
      else
        [calculate_amount_0(current_sqrt_price), calculate_amount_1(current_sqrt_price)]
      end
    end

    def calculate_amount_0(sqrt_ratio)
      (liquidity * ((sqrt_ratio_upper - sqrt_ratio) / (sqrt_ratio * sqrt_ratio_upper))).floor
    end

    def calculate_amount_1(sqrt_ratio)
      (liquidity * (sqrt_ratio - sqrt_ratio_lower)).floor
    end
  end
end
