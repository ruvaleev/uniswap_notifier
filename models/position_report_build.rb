# frozen_string_literal: true

class PositionReportBuild < ActiveRecord::Base
  belongs_to :portfolio_report_build

  validates :message_id, presence: true, uniqueness: true
end
