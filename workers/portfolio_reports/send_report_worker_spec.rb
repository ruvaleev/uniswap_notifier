# frozen_string_literal: true

module PortfolioReports
  class SendReportWorker
    include Sidekiq::Worker

    def perform(portfolio_report_id)
      PortfolioReport.find(portfolio_report_id).send_message
    end
  end
end
