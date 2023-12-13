# frozen_string_literal: true

module Builders
  module Position
    class FeesClaims
      include EventParseable

      def call(collects, initial_increase, decreases, liquidity_changes)
        collects_hash = sum_by_timestamp(collects.dup)
        decreases_hash = sum_by_timestamp(decreases.dup)
        build_fees_claims(collects_hash, decreases_hash, initial_increase, liquidity_changes)
      end

      private

      def sum_by_timestamp(collection)
        collection.each.with_object({}) do |log, result|
          timestamp = log[:timestamp]
          if result[timestamp]
            result[timestamp][:amount_0] += log[:amount_0]
            result[timestamp][:amount_1] += log[:amount_1]
          else
            result[timestamp] = log
          end
        end
      end

      def build_fees_claims(collects_hash, decreases_hash, initial_increase, liquidity_changes)
        last_change_timestamp = initial_increase[:timestamp]
        notional_position_usd_value = overall_usd_amount(initial_increase)
        collects_timestamps = collects_hash.keys.sort

        collects_timestamps.map do |timestamp|
          collect = collects_hash[timestamp].dup
          decrease = decreases_hash[timestamp]
          last_change_timestamp, notional_position_usd_value =
            update_position_usd_val(last_change_timestamp, notional_position_usd_value, liquidity_changes, timestamp)
          build_log(collect, decrease, notional_position_usd_value)
        end
      end

      def update_position_usd_val(last_change_timestamp, notional_position_usd_value, liquidity_changes, timestamp)
        applicable_changes = liquidity_changes.select do |key, _value|
          key < timestamp && key > last_change_timestamp
        end

        applicable_changes.each do |change_timestamp, change_value|
          last_change_timestamp = change_timestamp
          notional_position_usd_value += notional_position_usd_value * change_value / 100
        end
        [last_change_timestamp, notional_position_usd_value]
      end

      def build_log(collect, decrease, notional_position_usd_value)
        if decrease
          collect[:amount_0] -= decrease[:amount_0]
          collect[:amount_1] -= decrease[:amount_1]
        end
        collect[:notional_position_usd_value] = notional_position_usd_value

        collect_usd_amount = overall_usd_amount(collect)
        collect[:percent_of_deposit] = (100 * collect_usd_amount / notional_position_usd_value).round(4)

        collect
      end
    end
  end
end
