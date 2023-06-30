# frozen_string_literal: true

class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :ip_address, :token, :user_id, presence: true
end
