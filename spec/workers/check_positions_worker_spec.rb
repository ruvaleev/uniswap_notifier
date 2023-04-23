# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe CheckPositionsWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async }

    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }
    let(:balanced_position) { create(:position, **target_params) }
    let(:inactive_position) { create(:position, **target_params, status: :inactive) }
    let(:notified_position) { create(:position, **target_params, notification_status: :notified) }
    let(:target_position) { create(:position, **target_params) }
    let(:target_params) { { status: :active, notification_status: :unnotified } }

    before do
      balanced_position
      allow(Position).to receive(:to_rebalance).and_return(
        Position.where(id: [target_position, notified_position, inactive_position])
      )
      allow(TelegramNotifier).to receive(:new).with(target_position).and_return(telegram_notifier_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls TelegramNotifier with target positions only', testing: :inline do
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end
  end
end
