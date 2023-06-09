# frozen_string_literal: true

class PositionsCoin < ActiveRecord::Base
  belongs_to :coin
  belongs_to :position

  validates :coin_id, :number, :position_id, presence: true
  validates :number, uniqueness: { scope: :position_id }

  scope :to_rebalance, lambda { |rebalance_threshold|
    threshold = ActiveRecord::Base.connection.quote(rebalance_threshold)

    from(
      <<-SQL.squish
        positions_coins,
        LATERAL(
          SELECT
          ABS((max_price - min_price) / 100) * #{threshold} AS threshold_value,
          GREATEST(max_price, min_price) AS max_price_value,
          LEAST(max_price, min_price) AS min_price_value
        ) AS t1
      SQL
    ).where(
      <<-SQL.squish
        price <= (min_price_value + threshold_value) OR
        price >= (max_price_value - threshold_value)
      SQL
    )
  }
end
