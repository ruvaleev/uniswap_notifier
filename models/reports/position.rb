# frozen_string_literal: true

module Reports
  class Position < ActiveRecord::Base
    belongs_to :portfolio_report
    has_one :position_report, dependent: :destroy

    def report
      position_report || create_position_report!
    end
  end
end
