# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :authentications, dependent: :destroy
  has_many :notification_statuses, dependent: :destroy
  has_many :portfolio_reports, dependent: :destroy
  has_many :wallets, dependent: :destroy

  has_one :notifications_setting, dependent: :destroy

  validates :locale, presence: true

  def portfolio_report
    portfolio_reports.in_process.first || portfolio_reports.create!
  end
end
