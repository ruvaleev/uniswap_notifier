# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :authentications, dependent: :destroy
  has_many :notification_statuses, dependent: :destroy
  has_many :portfolio_report_builds, dependent: :destroy
  has_many :wallets, dependent: :destroy
end
