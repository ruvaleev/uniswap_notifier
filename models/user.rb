# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :authentications, dependent: :destroy
  has_many :notification_statuses, dependent: :destroy

  validates :address, presence: true, uniqueness: true
end
