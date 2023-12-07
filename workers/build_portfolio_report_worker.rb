# frozen_string_literal: true

class BuildPortfolioReportWorker
  include Sidekiq::Worker

  DEFAULT_THRESHOLD = 10

  def perform(user_id)
    user = User.find(user_id)
    Builders::PortfolioReport.new.call(user)
  end
end
