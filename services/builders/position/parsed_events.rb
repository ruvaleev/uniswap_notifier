# frozen_string_literal: true

module Builders
  module Position
    class ParsedEvents
      class EventsNotFound < StandardError; end

      def call(position)
        raise EventsNotFound if position.events.blank?

        update_position(position)
        position
      end

      private

      def update_position(position)
        params = update_params(position)
        position.update!(params)
      end

      def update_params(position) # rubocop:disable Metrics/MethodLength
        collects = Builders::Position::Events::Collects.new.call(position)
        liquidity_increases = Builders::Position::Events::LiquidityIncreases.new.call(position)
        liquidity_decreases = Builders::Position::Events::LiquidityDecreases.new.call(position)
        liquidity_changes = Builders::Position::LiquidityChanges.new.call(liquidity_increases, liquidity_decreases)
        initial_increase = liquidity_increases.min_by { |log| log[:timestamp] }
        fees_claims =
          Builders::Position::FeesClaims.new.call(collects, initial_increase, liquidity_decreases, liquidity_changes)
        hold_usd_value = Builders::Position::HoldUsdValue.new.call(initial_increase, liquidity_changes)

        {
          collects:,
          liquidity_increases:,
          liquidity_decreases:,
          liquidity_changes:,
          fees_claims:,
          hold_usd_value:
        }
      end
    end
  end
end
