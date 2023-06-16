# frozen_string_literal: true

module Positions
  class CheckByOwnerAddress
    class NotFoundError < StandardError; end

    def call(address, threshold)
      collection = api_service.positions_tickers(address, id_not_in: except_ids(address))
      check_positions_tickers(address, collection['data']['positions'], threshold)
    end

    private

    def check_positions_tickers(address, collection, threshold)
      collection.each do |record|
        NotifyOwnerWorker.perform_async(address, record['id']) if should_rebalance?(record, threshold)
      end
    end

    def except_ids(address)
      NotificationStatus.joins(:user).where(status: :notified, users: { address: }).pluck(:uniswap_id)
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
