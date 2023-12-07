# frozen_string_literal: true

module Builders
  class PortfolioReport
    def call(portfolio_report)
      case portfolio_report.status.to_sym
      when :initialized
        process_initialized_report(portfolio_report)
      when :positions_fetched
        process_positions_fetched_report(portfolio_report)
      when :prices_fetched
        process_prices_fetched_report(portfolio_report)
      end

      portfolio_report.send_message
    end

    private

    def process_initialized_report(portfolio_report)
      PortfolioReports::FetchPositions.new(portfolio_report).call
      portfolio_report.update!(status: :positions_fetched)
      call(portfolio_report)
    end

    def process_positions_fetched_report(portfolio_report)
      symbols = portfolio_report.positions.pluck(:token_0, :token_1).flatten.pluck('symbol').uniq
      prices = Coingecko::GetUsdPrice.new.call(*symbols)
      portfolio_report.update!(prices:, status: :prices_fetched)
      call(portfolio_report)
    end

    def process_prices_fetched_report(portfolio_report)
      positions = portfolio_report.positions
      threads = positions.each.with_object([]) do |pos, ar|
        ar << Thread.new { PositionReport.new.call(pos.report) }
      end
      threads.each(&:join)

      portfolio_report.update!(status: :completed)
    end
  end
end
