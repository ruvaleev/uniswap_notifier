# frozen_string_literal: true

module Reports
  class Position < ActiveRecord::Base
    class NoAmountsInfo < StandardError; end
    class NoEventsInfo < StandardError; end
    class NoFeesInfo < StandardError; end
    class NoHoldUsdValue < StandardError; end
    class NoInitialTimestamp < StandardError; end

    belongs_to :portfolio_report
    has_one :position_report, dependent: :destroy

    delegate :usd_price, to: :portfolio_report

    def age_days
      raise NoInitialTimestamp unless initial_timestamp

      ((Time.now - initial_timestamp) / 60 / 60 / 24).to_i
    end

    def claimed_fees_earned
      raise NoEventsInfo if events.blank?

      fees_claims.sum { |claim| claim_usd_amount(claim) }.round(2)
    end

    def divider_0
      @divider_0 ||= BigDecimal(10**token_0['decimals'].to_i)
    end

    def divider_1
      @divider_1 ||= BigDecimal(10**token_1['decimals'].to_i)
    end

    def expected_apr
      raise NoHoldUsdValue unless hold_usd_value

      current_percent = 100 * unclaimed_fees_earned / hold_usd_value
      claimed_percent = fees_claims.sum { |claim| BigDecimal(claim['percent_of_deposit']) }
      ((current_percent + claimed_percent) * 365 / age_days).round(4)
    end

    def impermanent_loss
      hold_usd_value - usd_value
    end

    def impermanent_loss_percent
      (100 * impermanent_loss / hold_usd_value).round(4)
    end

    def report
      position_report || create_position_report!
    end

    def token_0_amount
      BigDecimal(token_0['amount'])
    end

    def token_0_fees
      BigDecimal(token_0['fees'])
    end

    def token_0_fees_usd
      (usd_price(token_0['symbol']) * token_0_fees).round(2)
    end

    def token_0_symbol
      token_0['symbol']
    end

    def token_0_usd
      (usd_price(token_0['symbol']) * token_0_amount).round(2)
    end

    def token_1_amount
      BigDecimal(token_1['amount'])
    end

    def token_1_fees
      BigDecimal(token_1['fees'])
    end

    def token_1_fees_usd
      (usd_price(token_1['symbol']) * token_1_fees).round(2)
    end

    def token_1_symbol
      token_1['symbol']
    end

    def token_1_usd
      (usd_price(token_1['symbol']) * token_1_amount).round(2)
    end

    def total_fees_profit_in_usd
      claimed_fees_earned + unclaimed_fees_earned
    end

    def unclaimed_fees_earned
      token_params_in_usd(fees(token_0), fees(token_1))
    end

    def usd_value
      token_params_in_usd(amount(token_0), amount(token_1))
    end

    private

    def amount(token)
      token['amount'] ? BigDecimal(token['amount']) : raise(NoAmountsInfo)
    end

    def claim_usd_amount(claim)
      (BigDecimal(claim['amount_0']) * BigDecimal(claim['usd_price_0'])) +
        (BigDecimal(claim['amount_1']) * BigDecimal(claim['usd_price_1']))
    end

    def fees(token)
      token['fees'] ? BigDecimal(token['fees']) : raise(NoFeesInfo)
    end

    def token_params_in_usd(token_0_value, token_1_value)
      (
        (token_0_value * usd_price(token_0['symbol'])) +
          (token_1_value * usd_price(token_1['symbol']))
      ).round(2)
    end
  end
end
