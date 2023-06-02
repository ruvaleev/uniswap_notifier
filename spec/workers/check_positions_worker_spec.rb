# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe CheckPositionsWorker do
  describe '#perform' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:perform_worker) { described_class.perform_async }

    let(:update_pool_state_double) { instance_double(Positions::UpdatePoolState, call: true) }
    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }
    let(:balanced_position) { create(:position, **target_params) }
    let(:inactive_position) { create(:position, **target_params, status: :inactive) }
    let(:notified_position) { create(:position, **target_params, notification_status: :notified) }
    let(:target_position) { create(:position, **target_params) }
    let(:target_params) { { status: :active, notification_status: :unnotified } }
    let(:balanced_pos_coins) { create(:positions_coin, :balanced, position: balanced_position) }
    let(:inactive_pos_coins) { create(:positions_coin, :balanced, position: inactive_position) }
    let(:notified_pos_coins) { create(:positions_coin, :balanced, position: notified_position) }
    let(:target_pos_coins) { create(:positions_coin, :to_rebalance, position: target_position) }

    before do
      balanced_pos_coins
      inactive_pos_coins
      notified_pos_coins
      target_pos_coins
      allow(Positions::UpdatePoolState).to receive(:new).and_return(update_pool_state_double)
      allow(TelegramNotifier).to receive(:new).with(target_position).and_return(telegram_notifier_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'fetches pool state from blockchain for every active unnotified position', testing: :inline do
      perform_worker
      expect(update_pool_state_double).to have_received(:call).exactly(2).times
      expect(update_pool_state_double).to have_received(:call).with(balanced_position).once
      expect(update_pool_state_double).to have_received(:call).with(target_position).once
    end

    it 'calls TelegramNotifier with target positions only', testing: :inline do
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end
  end
end
