# frozen_string_literal: true

class Wallet < ActiveRecord::Base
  belongs_to :user

  validates :address, presence: true, uniqueness: true
end
