# frozen_string_literal: true

class NotificationStatus < ActiveRecord::Base
  belongs_to :user

  validates :status, :uniswap_id, :user_id, presence: true
  validates :uniswap_id, uniqueness: { scope: :user_id }

  enum status: { unnotified: 0, notified: 1 }
end
