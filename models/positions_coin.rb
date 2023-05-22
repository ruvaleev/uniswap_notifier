# frozen_string_literal: true

class PositionsCoin < ActiveRecord::Base
  belongs_to :coin
  belongs_to :position

  validates :coin_id, :number, :position_id, presence: true
  validates :number, uniqueness: { scope: :position_id }
end
