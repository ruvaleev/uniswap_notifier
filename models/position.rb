# frozen_string_literal: true

class Position < ActiveRecord::Base
  belongs_to :from_currency, class_name: :Currency, inverse_of: :from_positions, foreign_key: :from_currency_id
  belongs_to :to_currency, class_name: :Currency, inverse_of: :to_positions, foreign_key: :to_currency_id

  validates :from_currency_id,
            :max_price,
            :min_price,
            :notification_status,
            :rebalance_threshold_percents,
            :status,
            :to_currency_id,
            presence: true

  validates_numericality_of :rebalance_threshold_percents, less_than_or_equal_to: 50

  enum notification_status: { unnotified: 0, notified: 1 }
  enum status: { active: 0, inactive: 1 }

  scope :to_rebalance, lambda {
    from(
      <<-SQL.squish
        positions
        INNER JOIN currencies AS from_currencies ON from_currencies.id = positions.from_currency_id
        INNER JOIN currencies AS to_currencies ON to_currencies.id = positions.to_currency_id,
        LATERAL(
          SELECT
            from_currencies.usd_price / to_currencies.usd_price AS price,
            (from_currencies.usd_price / to_currencies.usd_price / 100) * positions.rebalance_threshold_percents
              AS threshold_value
        ) AS t1
      SQL
    ).where(
      <<-SQL.squish
        (price - threshold_value) <= positions.min_price OR
        (price + threshold_value) >= positions.max_price
      SQL
    )
  }
end
