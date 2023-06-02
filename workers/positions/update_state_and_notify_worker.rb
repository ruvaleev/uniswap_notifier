# frozen_string_literal: true

module Positions
  class UpdateStateAndNotifyWorker
    include Sidekiq::Worker

    def perform(position_id)
      position = Position.find(position_id)
      UpdatePoolState.new.call(position)
      notify_user(position)
    end

    private

    def notify_user(position)
      position.reload
      return if position.notified?

      NotifyUserWorker.perform_async(position.id) if position.need_rebalance?
    end
  end
end
