# frozen_string_literal: true

module Builders
  module Position
    class ParsedEvents
      class EventsNotFound < StandardError; end

      def call(position)
        raise EventsNotFound if position.events.blank?

        build_params(position)
      end

      private

      def build_params(position) # rubocop:disable Metrics/MethodLength
        collects = Builders::Position::Events::Collects.new.call(position)
        liquidity_increases = Builders::Position::Events::LiquidityIncreases.new.call(position)
        liquidity_decreases = Builders::Position::Events::LiquidityDecreases.new.call(position)
        liquidity_changes = Builders::Position::LiquidityChanges.new.call(liquidity_increases, liquidity_decreases)
        initial_increase = liquidity_increases.min_by { |log| log[:timestamp] }
        fees_claims =
          Builders::Position::FeesClaims.new.call(collects, initial_increase, liquidity_decreases, liquidity_changes)

        {
          collects:,
          liquidity_increases:,
          liquidity_decreases:,
          liquidity_changes:,
          fees_claims:,
          hold_usd_value: hodl_usd_value(initial_increase, liquidity_changes, position)
        }
      end

      def hodl_usd_value(initial_increase, liquidity_changes, position)
        Builders::Position::HoldUsdValue.new.call(
          initial_increase,
          liquidity_changes,
          position.usd_price(position.token_0['symbol']),
          position.usd_price(position.token_1['symbol'])
        )
      end
    end
  end
end
