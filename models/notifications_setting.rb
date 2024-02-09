# frozen_string_literal: true

class NotificationsSetting < ActiveRecord::Base
  belongs_to :user

  validates :out_of_range, :user_id, presence: true
  validates :user_id, uniqueness: true
end
