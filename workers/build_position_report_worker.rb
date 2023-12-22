# frozen_string_literal: true

class BuildPositionReportWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(position_report_id)
    report = PositionReport.find(position_report_id)
    Builders::PositionReport.new.call(report)
  end
end
