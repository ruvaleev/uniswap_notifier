# frozen_string_literal: true

class Wallet < ActiveRecord::Base
  belongs_to :user

  validates :address, :user, presence: true
  validates :address, uniqueness: true
end
