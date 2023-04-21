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
end
