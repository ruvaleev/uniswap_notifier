# frozen_string_literal: true

class Currency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
end
