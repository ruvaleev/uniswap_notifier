# frozen_string_literal: true

module Builders
  module Position
    class HoldUsdValue
      include EventParseable

      def call(initial_increase, liquidity_changes)
        usd_amount = overall_usd_amount(initial_increase)

        timestamps = liquidity_changes.keys.sort
        timestamps.each do |timestamp|
          usd_amount += usd_amount * liquidity_changes[timestamp] / 100
        end

        usd_amount.round(2)
      end
    end
  end
end
