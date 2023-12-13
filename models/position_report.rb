# frozen_string_literal: true

class PositionReport < ActiveRecord::Base
  belongs_to :position, class_name: 'Reports::Position'

  validates :message_id, uniqueness: true, allow_nil: true

  def send_message
    # TODO
    # Update :initial_message_id here.
  end
end
