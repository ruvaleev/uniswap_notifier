# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../concerns/workers_shared_examples'

RSpec.describe Positions::UpdateStateAndNotifyWorker do
  describe '#perform', testing: :inline do
    subject(:perform_worker) { described_class.perform_async(position_id) }

    let(:position_id) { position.id }
    let(:position) { create(:position) }
    let(:update_pool_state_double) { instance_double(Positions::UpdatePoolState, call: true) }

    before do
      allow(Positions::UpdatePoolState).to receive(:new).and_return(update_pool_state_double)
    end

    it_behaves_like 'sidekiq worker' do
      before { Sidekiq::Testing.fake! }
    end

    it 'calls Positions::UpdatePoolState service with found position', testing: :inline do
      perform_worker
      expect(update_pool_state_double).to have_received(:call).with(position).once
    end

    context 'when position not found' do
      let(:position_id) { 0 }

      it "raises proper error and doesn't call Positions::UpdatePoolState service" do
        expect { perform_worker }.to raise_error(ActiveRecord::RecordNotFound)
        expect(update_pool_state_double).not_to have_received(:call)
      end
    end

    context 'with position rebalancing' do
      before { allow(NotifyUserWorker).to receive(:perform_async) }

      context 'when position needs rebalance' do
        before { create(:positions_coin, :to_rebalance, position:) }

        it 'asynchronoysly sends notification to user' do
          perform_worker
          expect(NotifyUserWorker).to have_received(:perform_async).with(position.id).once
        end

        context 'when position is notified already' do
          let(:position) { create(:position, notification_status: :notified) }

          it "doesn't notify user" do
            perform_worker
            expect(NotifyUserWorker).not_to have_received(:perform_async)
          end
        end
      end

      context "when position doesn't need rebalance" do
        it "doesn't notify user" do
          perform_worker
          expect(NotifyUserWorker).not_to have_received(:perform_async)
        end
      end
    end
  end
end
