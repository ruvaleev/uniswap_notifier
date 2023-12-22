# frozen_string_literal: true

module Builders
  module Position
    class LiquidityChanges
      def call(increases, decreases)
        changes = absolute_changes(increases, decreases)
        relative_changes(changes)
      end

      private

      def absolute_changes(increases, decreases)
        result = {}
        write_change(increases, result) { |timestamp, liquidity| result[timestamp] += liquidity }
        write_change(decreases, result) { |timestamp, liquidity| result[timestamp] -= liquidity }
        result
      end

      def write_change(logs, result)
        logs.each do |log|
          timestamp = log[:timestamp]
          result[timestamp] ||= BigDecimal('0')
          yield(timestamp, log[:liquidity])
        end
      end

      def relative_changes(changes)
        timestamps = changes.keys.sort
        current_liquidity = changes[timestamps.first]

        timestamps[1..].each.with_object({}) do |timestamp, result|
          result[timestamp] = (100 * changes[timestamp] / current_liquidity).to_i
          current_liquidity += changes[timestamp]
        end
      end
    end
  end
end
