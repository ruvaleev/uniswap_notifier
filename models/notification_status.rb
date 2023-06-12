# frozen_string_literal: true

class NotificationStatus < ActiveRecord::Base
  belongs_to :user

  validates :status, presence: true
  validates :uniswap_id, presence: true, uniqueness: true

  enum status: { unnotified: 0, notified: 1 }
end
