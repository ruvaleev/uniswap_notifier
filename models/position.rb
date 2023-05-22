# frozen_string_literal: true

class Position < ActiveRecord::Base
  belongs_to :user
  has_many :positions_coins, dependent: :restrict_with_error
  has_many :coins, through: :positions_coins, dependent: :restrict_with_error

  validates :notification_status,
            :rebalance_threshold_percents,
            :status,
            :user_id,
            presence: true

  validates_numericality_of :rebalance_threshold_percents, less_than_or_equal_to: 50

  enum notification_status: { unnotified: 0, notified: 1 }
  enum status: { active: 0, inactive: 1 }
end
