# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'
require './spec/services/builders/concerns/builders_shared'
require './spec/services/concerns/graph_shared'

RSpec.describe Builders::PortfolioReport do
  describe '#call' do
    subject(:call_service) { service.call(report) }

    let(:service) { described_class.new }
    let(:report) { portfolio_report }
    let(:portfolio_report) { create(:portfolio_report, user:, status:) }
    let(:user) { create(:user) }
    let(:wallet) { create(:wallet, user:) }

    before { wallet }

    include_context 'with recursively called service'
    include_context 'with mocked graph positions request'

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
      context 'when status: :initialized' do
        let(:status) { :initialized }

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'positions_fetched'

        it 'fetches positions for existing portfolio' do
          expect { call_service }.to change(portfolio_report.reload.positions, :count).by(2)
        end
      end

      context 'when status: :positions_fetched' do
        let(:status) { :positions_fetched }
        let!(:position_1) do # rubocop:disable RSpec/LetSetup
          create(:position, portfolio_report:, token_0: { 'symbol' => 'ARB' }, token_1: { 'symbol' => 'USDC' })
        end
        let!(:position_2) do # rubocop:disable RSpec/LetSetup
          create(:position, portfolio_report:, token_0: { 'symbol' => 'USDC' }, token_1: { 'symbol' => 'WETH' })
        end
        let(:prices) { { 'ARB' => 0.920302, 'USDC' => 0.998581, 'WETH' => 1699.14 } }
        let(:get_price_double) { instance_double(Coingecko::GetUsdPrice) }

        before do
          allow(Coingecko::GetUsdPrice).to receive(:new).and_return(get_price_double)
          allow(get_price_double).to receive(:call).with('ARB', 'USDC', 'WETH').and_return(prices)
        end

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'prices_fetched'

        it 'fetches prices and writes them to the report' do
          expect { call_service }.to change(portfolio_report.reload, :prices).to(prices)
        end
      end

      context 'when status: :prices_fetched' do
        let(:status) { :prices_fetched }
        let(:position_1) { create(:position, portfolio_report:, uniswap_id: 1000) }
        let(:position_2) { create(:position, portfolio_report:, uniswap_id: 1001) }
        let(:position_manager_double) { instance_double(Blockchain::Arbitrum::PositionManager, logs:) }

        include_context 'with mocked positions logs'

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'events_fetched'

        it 'fetches positions events logs and write results to the positions respectively with 1 query' do
          position_1
          position_2
          expect { call_service }.not_to exceed_query_limit(1).with(/^UPDATE positions/)
          expect(position_1.reload.events).to eq(log_1000)
          expect(position_2.reload.events).to eq(log_1001)
        end
      end

      context 'when status: :events_fetched', :multithreaded do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:status) { :events_fetched }
        let(:position_1) { create(:position, portfolio_report:) }
        let!(:position_report_1) { create(:position_report, position: position_1) }
        let(:position_2) { create(:position, portfolio_report:) }
        let!(:position_report_2) { create(:position_report, position: position_2) }
        let(:position_report_builder_double) { instance_double(Builders::PositionReport, call: true) }

        before do
          allow(Builders::PositionReport).to receive(:new).and_return(position_report_builder_double)
        end

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"
        it_behaves_like 'updates status to', 'completed'

        it 'calls Builders::PositionReport for each position' do
          call_service
          expect(position_report_builder_double).to have_received(:call).with(position_report_1).once
          expect(position_report_builder_double).to have_received(:call).with(position_report_2).once
        end
      end
    end
  end
end
