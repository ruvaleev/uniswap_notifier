# frozen_string_literal: true

module Queries
  module Positions
    class ToRebalance
      attr_accessor :relation

      def initialize(relation = User.all)
        @relation = relation
      end

      def call # rubocop:disable Metrics/MethodLength
        relation
          .from(
            <<-SQL.squish
              positions
              LEFT OUTER JOIN positions_coins ON positions_coins.position_id = positions.id,
              LATERAL(
                SELECT
                  (
                    (positions_coins.max_price - positions_coins.min_price) / 100
                  ) * positions.rebalance_threshold_percents
                    AS threshold_value
              ) AS t1
            SQL
          ).where(
            <<-SQL.squish
              positions_coins.price <= (positions_coins.min_price + threshold_value) OR
              positions_coins.price >= (positions_coins.max_price - threshold_value)
            SQL
          )
      end
    end
  end
end
