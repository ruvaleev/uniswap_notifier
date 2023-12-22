# frozen_string_literal: true

module Builders
  class PositionReport::Message # rubocop:disable Style/ClassAndModuleChildren
    def call(report) # rubocop:disable Metrics/MethodLength
      case report.status.to_sym
      when :initialized
        initialized_message(report.position)
      when :fees_info_fetching
        fees_info_fetching_message(report.position)
      when :history_analyzing
        history_analyzing_message(report.position)
      when :completed
        completed_message(report.position)
      when :failed
        failed_message(report)
      end
    end

    private

    def initialized_message(position)
      I18n.t('position_reports.initialized', uniswap_id: position.uniswap_id)
    end

    def fees_info_fetching_message(position)
      I18n.t('position_reports.fees_info_fetching', uniswap_id: position.uniswap_id)
    end

    def history_analyzing_message(position)
      I18n.t('position_reports.history_analyzing', uniswap_id: position.uniswap_id)
    end

    def completed_message(position) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      I18n.t(
        'position_reports.completed',
        uniswap_id: position.uniswap_id,
        age_days: position.age_days,
        token_0_symbol: position.token_0_symbol,
        token_0_amount: position.token_0_amount,
        token_0_usd: position.token_0_usd,
        token_0_fees: position.token_0_fees,
        token_0_fees_usd: position.token_0_fees_usd,
        token_1_symbol: position.token_1_symbol,
        token_1_amount: position.token_1_amount,
        token_1_usd: position.token_1_usd,
        token_1_fees: position.token_1_fees,
        token_1_fees_usd: position.token_1_fees_usd,
        usd_value: position.usd_value,
        unclaimed_fees_earned: position.unclaimed_fees_earned,
        expected_apr: position.expected_apr,
        impermanent_loss_percent: position.impermanent_loss_percent,
        impermanent_loss: position.impermanent_loss
      )
    end

    def failed_message(report)
      I18n.t(
        'position_reports.failed',
        error_message: report.error_message,
        uniswap_id: report.position.uniswap_id
      )
    end
  end
end
