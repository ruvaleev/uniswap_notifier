# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::CheckByOwnerAddress do
  describe '#call' do
    subject(:call_service) { service.call }

    let(:service) { described_class.new(address, threshold) }
    let(:address) { SecureRandom.hex }
    let(:threshold) { 10 }
    let(:graph_double) { instance_double(Graphs::RevertFinance) }
    let(:positions_tickers_json) do
      JSON.parse(File.read('spec/fixtures/graphs/revert_finance/positions_tickers.json'))
    end

    before do
      allow(Graphs::RevertFinance).to receive(:new).and_return(graph_double)
      allow(graph_double).to receive(:positions_tickers).with(address).and_return(positions_tickers_json)
    end

    after { Sidekiq::Worker.clear_all }

    it 'sends :out_of_range notification for positions to rebalance and :initial for other positions' do
      expect { call_service }.to change(NotifyOwnerWorker.jobs, :size).by(2)
      expect(NotifyOwnerWorker.jobs.pluck('args')).to match_array(
        [[address, '1', 'in_range'], [address, '2', 'out_of_range']]
      )
    end

    context 'when there is no positions for notification with provided threshold' do
      let(:threshold) { 0 }

      it 'sends proper messages for every positions' do
        expect { call_service }.to change(NotifyOwnerWorker.jobs, :size).by(2)
        expect(NotifyOwnerWorker.jobs.pluck('args')).to match_array(
          [[address, '1', 'in_range'], [address, '2', 'in_range']]
        )
      end
    end

    context 'when there are positions already in db' do
      let(:wallet) { create(:wallet, address:) }
      let(:user) { wallet.user }

      before { notification_status }

      context 'when status is the same' do
        let(:notification_status) { create(:notification_status, uniswap_id: 1, status: :in_range, user:) }

        it "doesn't send this notification" do
          expect { call_service }.to change(NotifyOwnerWorker.jobs, :size).by(1)
          expect(NotifyOwnerWorker.jobs.pluck('args')).to match_array([[address, '2', 'out_of_range']])
        end
      end

      context 'when status has changed' do
        let(:notification_status) { create(:notification_status, uniswap_id: 1, status: :out_of_range) }

        it 'sends this notification again' do
          expect { call_service }.to change(NotifyOwnerWorker.jobs, :size).by(2)
          expect(NotifyOwnerWorker.jobs.pluck('args')).to match_array(
            [[address, '1', 'in_range'], [address, '2', 'out_of_range']]
          )
        end
      end
    end
  end
end
