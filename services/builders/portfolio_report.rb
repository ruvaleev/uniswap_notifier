# frozen_string_literal: true

module Builders
  class PortfolioReport
    def call(portfolio_report) # rubocop:disable Metrics/MethodLength
      portfolio_report.send_initial_message

      case portfolio_report.status.to_sym
      when :positions_fetching
        process_positions_fetching_report(portfolio_report)
      when :prices_fetching
        process_prices_fetching_report(portfolio_report)
      when :events_fetching
        process_events_fetching_report(portfolio_report)
      when :results_analyzing
        process_results_analyzing_report(portfolio_report)
      when :completed
        portfolio_report.send_summary_message
      end
    end

    private

    def process_positions_fetching_report(portfolio_report)
      PortfolioReports::FetchPositions.new(portfolio_report).call
      portfolio_report.update!(status: :prices_fetching)
      call(portfolio_report)
    end

    def process_prices_fetching_report(portfolio_report)
      symbols = portfolio_report.positions.pluck(:token_0, :token_1).flatten.pluck('symbol').uniq
      prices = Coingecko::GetUsdPrice.new.call(*symbols)
      portfolio_report.update!(prices:, status: :events_fetching)
      call(portfolio_report)
    end

    def process_events_fetching_report(portfolio_report)
      positions = portfolio_report.positions
      uniswap_ids = positions.pluck(:uniswap_id)
      logs = Blockchain::Arbitrum::PositionManager.new.logs(*uniswap_ids)
      save_logs(positions, logs)
      portfolio_report.update!(status: :results_analyzing)
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

    def process_results_analyzing_report(portfolio_report)
      position_reports = ::PositionReport.joins(:position).where(position: { portfolio_report_id: portfolio_report.id })
      to_process = position_reports.initialized
      return schedule_position_reports(to_process) if to_process.any?

      complete_report(portfolio_report) if position_reports.in_process.none?
    end

    def schedule_position_reports(position_reports)
      position_reports.find_each { |report| BuildPositionReportWorker.perform_async(report.id) }
    end

    def complete_report(portfolio_report)
      portfolio_report.update!(status: :completed)
      call(portfolio_report)
    end
  end
end
