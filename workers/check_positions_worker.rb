# frozen_string_literal: true

class CheckPositionsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    Position.to_rebalance.active.unnotified.select(:id).each_slice(1000) do |batch|
      Sidekiq::Client.push_bulk(
        'class' => NotifyUserWorker,
        'args' => batch.map { |payload| [payload[:id]] }
      )
    end
  end
end
