# frozen_string_literal: true

module Builders
  class PortfolioReport::InitialMessage # rubocop:disable Style/ClassAndModuleChildren
    def call(report)
      I18n.t("portfolio_reports.#{report.status}", **locale_params(report))
    end

    private

    def locale_params(report)
      case report.status.to_sym
      when :completed
        { prices_as_string: report.prices_as_string }
      when :failed
        { error_message: report.error_message }
      else
        {}
      end
    end
  end
end
