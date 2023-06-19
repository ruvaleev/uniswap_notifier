# frozen_string_literal: true

module Positions
  class CheckByOwnerAddress
    class NotFoundError < StandardError; end

    attr_reader :address, :threshold

    def initialize(address, threshold)
      @address = address
      @threshold = threshold
    end

    def call
      collection = api_service.positions_tickers(address)
      check_positions_tickers(address, collection['data']['positions'], threshold)
    end

    private

    def notification_statuses
      @notification_statuses ||=
        NotificationStatus.joins(:user).where(users: { address: })
                          .select(:status, :uniswap_id).to_h { |rec| [rec.uniswap_id.to_s, rec.status] }
    end

    def check_positions_tickers(address, collection, threshold)
      collection.each do |record|
        uniswap_id = record['id']
        if should_rebalance?(record, threshold)
          notify(address, uniswap_id, 'out_of_range')
        else
          notify(address, uniswap_id, 'in_range')
        end
      end
    end

    def notify(address, uniswap_id, status)
      return if notification_statuses[uniswap_id] == status

      NotifyOwnerWorker.perform_async(address, uniswap_id, status)
    end

    def api_service
      @api_service ||= Graphs::RevertFinance.new
    end

    def should_rebalance?(record, threshold)
      should_rebalance_service.call(
        current_tick: record['pool']['tick'].to_i,
        lower_tick: record['tickLower'].to_i,
        upper_tick: record['tickUpper'].to_i,
        threshold:
      )
    end

    def should_rebalance_service
      @should_rebalance_service ||= Positions::ShouldRebalanceCheck.new
    end
  end
end
