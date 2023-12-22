# frozen_string_literal: true

class BuildPortfolioReportWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    Builders::PortfolioReport.new.call(user.portfolio_report)
  end
end
