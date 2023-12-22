# frozen_string_literal: true

class PositionReport < ActiveRecord::Base
  belongs_to :position, class_name: 'Reports::Position'

  validates :message_id, uniqueness: true, allow_nil: true
  validates :position, presence: true, uniqueness: true

  scope :in_process, -> { where(status: %i[fees_info_fetching history_analyzing]) }
  scope :initialized, -> { where(status: :initialized) }

  def send_message
    result = message_service.call(message_id:, chat_id:, text:)
    update!(message_id: result['result']['message_id']) unless message_id
  end

  private

  def chat_id
    @chat_id ||=
      User.joins(portfolio_reports: :positions)
          .where(positions: { id: position_id }).pluck(:telegram_chat_id).first
  end

  def text
    message_builder.call(self)
  end

  def message_builder
    @message_builder ||= Builders::PositionReport::Message.new
  end

  def message_service
    @message_service ||= Telegram::Reports::SendOrUpdateMessage.new
  end
end
