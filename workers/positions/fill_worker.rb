# frozen_string_literal: true

module Positions
  class FillWorker
    include Sidekiq::Worker

    def perform(position_id)
      Fill.new.call(
        Position.find(position_id), { status: :active }
      )
    end
  end
end
