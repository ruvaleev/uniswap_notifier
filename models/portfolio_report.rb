# frozen_string_literal: true

class PortfolioReport < ActiveRecord::Base
  belongs_to :user

  has_many :positions, class_name: 'Reports::Position', dependent: :destroy

  validates :initial_message_id, uniqueness: true

  scope :in_process, -> { where(status: %i[initialized positions_fetched prices_fetched]) }

  def send_message
    # TODO
    # Update :initial_message_id here.
  end
end
