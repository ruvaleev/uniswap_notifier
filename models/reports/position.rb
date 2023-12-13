# frozen_string_literal: true

module Reports
  class Position < ActiveRecord::Base
    belongs_to :portfolio_report
    has_one :position_report, dependent: :destroy

    def divider_0
      @divider_0 ||= BigDecimal(10**token_0['decimals'])
    end

    def divider_1
      @divider_1 ||= BigDecimal(10**token_1['decimals'])
    end

    def report
      position_report || create_position_report!
    end
  end
end
