# frozen_string_literal: true

module Builders
  module Position
    class HoldUsdValue
      def call(initial_increase, liquidity_changes, token_0_price, token_1_price)
        token_0_amount = initial_increase[:amount_0]
        token_1_amount = initial_increase[:amount_1]

        (
          ((token_0_amount * token_0_price) + (token_1_amount * token_1_price)) *
            changes_coefficient(liquidity_changes)
        ).round(2)
      end

      private

      def changes_coefficient(liquidity_changes)
        coef = BigDecimal('1')
        timestamps = liquidity_changes.keys.sort
        timestamps.each do |timestamp|
          coef += coef * liquidity_changes[timestamp] / 100
        end
        coef
      end
    end
  end
end
