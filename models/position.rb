# frozen_string_literal: true

class Position < ActiveRecord::Base
  belongs_to :user
  belongs_to :coin0, class_name: :Coin, inverse_of: :coin0_positions, foreign_key: :coin0_id
  belongs_to :coin1, class_name: :Coin, inverse_of: :coin1_positions, foreign_key: :coin1_id

  validates :coin0_id,
            :coin1_id,
            :notification_status,
            :rebalance_threshold_percents,
            :status,
            :user_id,
            presence: true

  validates_numericality_of :rebalance_threshold_percents, less_than_or_equal_to: 50

  enum notification_status: { unnotified: 0, notified: 1 }
  enum status: { active: 0, inactive: 1 }
end
