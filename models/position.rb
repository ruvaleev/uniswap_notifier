# frozen_string_literal: true

class Position < ActiveRecord::Base
  belongs_to :user
  has_many :positions_coins, dependent: :restrict_with_error
  has_many :coins, through: :positions_coins, dependent: :restrict_with_error

  validates :notification_status,
            :rebalance_threshold_percents,
            :status,
            :uniswap_id,
            :user_id,
            presence: true
  validates :uniswap_id, uniqueness: { scope: :user_id }

  validates_numericality_of :rebalance_threshold_percents, less_than_or_equal_to: 50

  enum notification_status: { unnotified: 0, notified: 1 }
  enum status: { pending: 0, active: 1, inactive: 2, failed: 3 }
end
