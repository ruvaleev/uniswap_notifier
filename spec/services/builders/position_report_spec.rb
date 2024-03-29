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
    let(:position) { build(:position, **position_params) }
    let(:position_params) { {} }

    include_context 'with mocked send_message service'
    include_context 'with recursively called service'

    context 'when report is in one of completed statuses' do
      context 'when status: :failed' do
        let(:status) { :failed }

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"
      end

      context 'when status: :completed' do
        let(:status) { :completed }

        include_context 'with mocked position_report build_message service'

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"

        it 'calls Builders::PortfolioReport with position parent portfolio_report' do
          expect { call_service }.to change(BuildPortfolioReportWorker.jobs, :size).by(1)
          expect(BuildPortfolioReportWorker.jobs.pluck('args')).to match_array([[position.portfolio_report.user_id]])
        end
      end
    end

    context 'when report is in one of processing statuses' do
      context 'when status: :initialized' do
        let(:status) { :initialized }

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'fees_info_fetching'
      end

      context 'when status: :fees_info_fetching' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:status) { :fees_info_fetching }
        let(:position_params) { { pool: { id: pool_address } } }
        let(:pool_address) { rand_blockchain_address }

        let(:tick_lower) { Tick.new(1, 2) }
        let(:tick_upper) { Tick.new(1, 2) }
        let(:pool_contract_double) { instance_double(Blockchain::Arbitrum::PoolContract) }
        let(:calculate_fees_double) { instance_double(Positions::CalculateFees, call: fees_info) }
        let(:calculate_amounts_double) { instance_double(Positions::CalculateAmounts, call: amounts_info) }
        let(:fees_info) { { fees_0: 0.5, fees_1: 5 } }
        let(:amounts_info) { { amount_0: 10, amount_1: 20 } }

        before do
          allow(Blockchain::Arbitrum::PoolContract).to receive(:new)
            .with(pool_address).and_return(pool_contract_double)
          allow(pool_contract_double).to receive(:ticks).with(position.tick_lower).and_return(tick_lower)
          allow(pool_contract_double).to receive(:ticks).with(position.tick_upper).and_return(tick_upper)
          allow(Positions::CalculateFees).to receive(:new)
            .with(position, tick_lower, tick_upper).and_return(calculate_fees_double)
          allow(Positions::CalculateAmounts).to receive(:new)
            .with(position).and_return(calculate_amounts_double)
        end

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'history_analyzing'

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

    context 'when status: :history_analyzing' do
      let(:status) { :history_analyzing }
      let(:position) { create(:position, events: log_1001) }
      let(:pool_response_body) { File.read('spec/fixtures/graphs/revert_finance/pool/200_success.json') }
      let(:pool_uri) { 'https://api.thegraph.com/subgraphs/name/revert-finance/uniswap-v3-arbitrum' }

      before { stub_request(:post, pool_uri).to_return(body: pool_response_body, status: 200) }

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
        expect(position.liquidity_changes).to eq(liquidity_changes_1001)
        expect(position.hold_usd_value).to eq(11_434.84)
        expect(position.initial_timestamp).to eq(Time.at(1_695_009_234))
        expect(position.initial_tick).to eq(76_046)
      end
    end
  end
end
