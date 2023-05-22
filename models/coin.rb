# frozen_string_literal: true

class Coin < ActiveRecord::Base
  has_many :positions_coins, dependent: :restrict_with_error
  has_many :positions, through: :positions_coins, dependent: :restrict_with_error

  validates :address, :symbol, :decimals, :name, presence: true
  validates :address, uniqueness: true
end
