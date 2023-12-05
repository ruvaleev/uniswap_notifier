# frozen_string_literal: true

class PortfolioReportBuild < ActiveRecord::Base
  belongs_to :user

  has_many :position_report_builds, dependent: :destroy

  validates :initial_message_id, presence: true, uniqueness: true
end
