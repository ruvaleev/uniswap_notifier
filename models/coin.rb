# frozen_string_literal: true

class Coin < ActiveRecord::Base
  has_many :coin0_positions, class_name: :Position, foreign_key: :coin0_id, dependent: :destroy
  has_many :coin1_positions, class_name: :Position, foreign_key: :coin1_id, dependent: :destroy

  validates :address, :symbol, :decimals, :name, presence: true
  validates :address, uniqueness: true
end
