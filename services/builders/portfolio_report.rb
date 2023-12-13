# frozen_string_literal: true

module Builders
  class PortfolioReport
    def call(portfolio_report) # rubocop:disable Metrics/MethodLength
      portfolio_report.send_message

      case portfolio_report.status.to_sym
      when :initialized
        process_initialized_report(portfolio_report)
      when :positions_fetched
        process_positions_fetched_report(portfolio_report)
      when :prices_fetched
        process_prices_fetched_report(portfolio_report)
      when :events_fetched
        process_events_fetched_report(portfolio_report)
      end
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
      uniswap_ids = positions.pluck(:uniswap_id)
      logs = Blockchain::Arbitrum::PositionManager.new.logs(*uniswap_ids)
      save_logs(positions, logs)
      portfolio_report.update!(status: :events_fetched)
      call(portfolio_report)
    end

    def save_logs(positions, logs) # rubocop:disable Metrics/MethodLength
      return if positions.blank?

      uniswap_ids = logs.keys
      case_when_clause = uniswap_ids.map do |uniswap_id|
        json_data = ActiveRecord::Base.connection.quote(logs[uniswap_id].to_json)
        "WHEN uniswap_id = #{uniswap_id} THEN #{json_data}"
      end.join(' ')
      id_list = positions.pluck(:id).join(', ')

      sql = <<-SQL.squish
        UPDATE positions
        SET events = CASE
          #{case_when_clause}
          ELSE events
        END
        WHERE id IN (#{id_list})
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end

    def process_events_fetched_report(portfolio_report)
      positions = portfolio_report.positions
      threads = positions.each.with_object([]) do |pos, ar|
        ar << Thread.new { PositionReport.new.call(pos.report) }
      end
      threads.each(&:join)

      portfolio_report.update!(status: :completed)
    end
  end
end
