# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'
require './spec/services/builders/concerns/builders_shared'
require './spec/services/concerns/graph_shared'

RSpec.describe Builders::PositionReport do
  describe '#call' do
    subject(:call_service) { service.call(report) }

    let(:service) { described_class.new }
    let(:report) { position_report }
    let(:position_report) { create(:position_report, status:, position:) }
    let(:position) { build(:position) }

    include_context 'with recursively called service'

    context 'when report is in one of completed statuses' do
      context 'when status: :failed' do
        let(:status) { :failed }

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"
      end

      context 'when status: :completed' do
        let(:status) { :completed }

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"
      end
    end

    context 'when report is in one of processing statuses' do
      context 'when status: :initialized' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:status) { :initialized }

        let(:tick_lower) { Tick.new(1, 2) }
        let(:tick_upper) { Tick.new(1, 2) }
        let(:pool_contract_double) { instance_double(Blockchain::Arbitrum::PoolContract) }
        let(:calculate_fees_double) { instance_double(Positions::CalculateFees, call: fees_info) }
        let(:calculate_amounts_double) { instance_double(Positions::CalculateAmounts, call: amounts_info) }
        let(:fees_info) { { fees_0: 0.5, fees_1: 5 } }
        let(:amounts_info) { { amount_0: 10, amount_1: 20 } }

        before do
          allow(Blockchain::Arbitrum::PoolContract).to receive(:new)
            .with(position.owner).and_return(pool_contract_double)
          allow(pool_contract_double).to receive(:ticks).with(position.tick_lower).and_return(tick_lower)
          allow(pool_contract_double).to receive(:ticks).with(position.tick_upper).and_return(tick_upper)
          allow(Positions::CalculateFees).to receive(:new)
            .with(position, tick_lower, tick_upper).and_return(calculate_fees_double)
          allow(Positions::CalculateAmounts).to receive(:new)
            .with(position).and_return(calculate_amounts_double)
        end

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'fees_info_fetched'

        it 'fetches info about ticks, calculates fees and writes results to the DB' do
          call_service
          position.reload
          expect(position.token_0['amount']).to eq(10)
          expect(position.token_0['fees']).to eq(0.5)
          expect(position.token_1['amount']).to eq(20)
          expect(position.token_1['fees']).to eq(5)
        end
      end
    end

    context 'when status: :fees_info_fetched' do
      let(:status) { :fees_info_fetched }
      let(:position) { create(:position, events: log_1001) }

      include_context 'with mocked block_timestamp'
      include_context 'with mocked Coingecko::GetHistoricalPrice'
      include_context 'with mocked positions logs'

      it_behaves_like 'sends report'
      it_behaves_like 'calls itself recursively'
      it_behaves_like 'updates status to', 'completed'

      it 'fetches historical prices and enriches events with it' do
        call_service
        expect(position.collects.to_json).to eq(collects_1001.to_json)
        expect(position.liquidity_decreases.to_json).to eq(liquidity_decreases_1001.to_json)
        expect(position.liquidity_increases.to_json).to eq(liquidity_increases_1001.to_json)
        expect(position.fees_claims.to_json).to eq(fees_claims_1001.to_json)
        expect(position.liquidity_changes).to eq({ '1698175159' => -50, '1700743351' => -50 })
        expect(position.hold_usd_value).to eq(7770.92)
      end
    end
  end
end
