# frozen_string_literal: true

module Builders
  class PortfolioReport::SummaryMessage # rubocop:disable Style/ClassAndModuleChildren
    def call(report)
      summary_message(report.usd_value, report.unclaimed_fees, report.claimed_fees)
    end

    private

    def summary_message(usd_value, unclaimed_fees, claimed_fees)
      I18n.t('portfolio_reports.summary_message',
             usd_value:,
             unclaimed_fees:,
             claimed_fees:,
             total_fees: unclaimed_fees + claimed_fees)
    end
  end
end
