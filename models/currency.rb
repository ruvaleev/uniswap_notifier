# frozen_string_literal: true

class Currency < ActiveRecord::Base
  has_many :from_positions, class_name: :Position, foreign_key: :from_currency_id, dependent: :destroy
  has_many :to_positions, class_name: :Position, foreign_key: :to_currency_id, dependent: :destroy

  validates :code, presence: true, uniqueness: true
end
