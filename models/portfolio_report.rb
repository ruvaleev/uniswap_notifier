# frozen_string_literal: true

class PortfolioReport < ActiveRecord::Base
  class NoUsdPricesInfo < StandardError; end

  belongs_to :user

  has_many :positions, class_name: 'Reports::Position', dependent: :destroy

  validates :initial_message_id, uniqueness: true, allow_nil: true

  scope :in_process, -> { where(status: %i[positions_fetching prices_fetching events_fetching results_analyzing]) }

  def claimed_fees
    positions.sum(&:claimed_fees_earned)
  end

  def prices_as_string
    prices.sort.map { |sym, price| "#{sym}: $#{price.round(2)}" }.join(', ')
  end

  def send_initial_message
    send_message(text: initial_message_text, id_field: :initial_message_id)
  end

  def send_summary_message
    send_message(text: summary_message_text, id_field: :summary_message_id)
  end

  def unclaimed_fees
    positions.sum(&:unclaimed_fees_earned)
  end

  def usd_price(symbol)
    prices[symbol] || raise(NoUsdPricesInfo)
  end

  def usd_value
    positions.sum(&:usd_value)
  end

  private

  def chat_id
    @chat_id ||= user.telegram_chat_id
  end

  def initial_message_text
    initial_message_builder.call(self)
  end

  def initial_message_builder
    @initial_message_builder ||= Builders::PortfolioReport::InitialMessage.new
  end

  def message_service
    @message_service ||= Telegram::Reports::SendOrUpdateMessage.new
  end

  def send_message(text:, id_field:)
    message_id = public_send(id_field)
    result = message_service.call(chat_id:, message_id:, text:)
    update!(id_field => result['result']['message_id']) unless message_id
  end

  def summary_message_text
    summary_message_builder.call(self)
  end

  def summary_message_builder
    @summary_message_builder ||= Builders::PortfolioReport::SummaryMessage.new
  end
end
