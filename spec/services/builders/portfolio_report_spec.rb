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
    let(:position_1) { create(:position, portfolio_report:, uniswap_id: 1000) }
    let(:user) { create(:user, telegram_chat_id: rand(100)) }
    let(:wallet) { create(:wallet, user:) }

    include_context 'with mocked positions logs'

    include_context 'with mocked send_message service'
    include_context 'with recursively called service'
    include_context 'with mocked graph positions request'

    before do
      position_1
      wallet
    end

    context 'when report is in one of completed statuses' do
      context 'when status: :failed' do
        let(:status) { :failed }

        it_behaves_like 'sends report'
        it_behaves_like "doesn't call itself recursively"
      end

      context 'when status: :completed' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:status) { :completed }

        let(:initial_message_text) { 'Initial Message' }
        let(:initial_message_builder_double) do
          instance_double(Builders::PortfolioReport::InitialMessage, call: initial_message_text)
        end
        let(:summary_message_text) { 'Summary Message' }
        let(:summary_message_builder_double) do
          instance_double(Builders::PortfolioReport::SummaryMessage, call: summary_message_text)
        end

        before do
          allow(Builders::PortfolioReport::InitialMessage).to receive(:new).and_return(initial_message_builder_double)
          allow(Builders::PortfolioReport::SummaryMessage).to receive(:new).and_return(summary_message_builder_double)
        end

        it 'updates initial message and sends one summary message' do # rubocop:disable RSpec/ExampleLength
          call_service
          expect(send_message_service_double).to have_received(:call).with(
            chat_id: user.telegram_chat_id,
            message_id: portfolio_report.initial_message_id,
            text: initial_message_text
          ).once
          expect(send_message_service_double).to have_received(:call).with(
            chat_id: user.telegram_chat_id,
            message_id: nil,
            text: summary_message_text
          ).once
        end
      end
    end

    context 'when report is in one of processing statuses' do
      context 'when status: :positions_fetching' do
        let(:status) { :positions_fetching }

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'prices_fetching'

        it 'fetches positions for existing portfolio' do
          expect { call_service }.to change(portfolio_report.reload.positions, :count).by(2)
        end
      end

      context 'when status: :prices_fetching' do
        let(:status) { :prices_fetching }
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
        it_behaves_like 'updates status to', 'events_fetching'

        it 'fetches prices and writes them to the report' do
          expect { call_service }.to change(portfolio_report.reload, :prices).to(prices)
        end
      end

      context 'when status: :events_fetching' do
        let(:status) { :events_fetching }
        let!(:position_2) { create(:position, portfolio_report:, uniswap_id: 1001) }

        include_context 'with mocked positions logs'

        it_behaves_like 'sends report'
        it_behaves_like 'calls itself recursively'
        it_behaves_like 'updates status to', 'results_analyzing'

        it 'fetches positions events logs and write results to the positions respectively with 1 query' do
          expect { call_service }.not_to exceed_query_limit(1).with(/^UPDATE positions/)
          expect(position_1.reload.events).to eq(log_1000)
          expect(position_2.reload.events).to eq(log_1001)
        end
      end

      context 'when status: :results_analyzing' do
        let(:status) { :results_analyzing }
        let(:position_report_builder_double) { instance_double(Builders::PositionReport, call: true) }

        before do
          allow(Builders::PositionReport).to receive(:new).and_return(position_report_builder_double)
        end

        it_behaves_like 'sends report'

        context 'when report has :initialized positions' do # rubocop:disable RSpec/MultipleMemoizedHelpers
          let(:position_1) { create(:position, portfolio_report:) }
          let!(:position_report_1) { create(:position_report, position: position_1, status: :initialized) }
          let(:position_2) { create(:position, portfolio_report:) }
          let!(:position_report_2) { create(:position_report, position: position_2, status: :initialized) }

          it_behaves_like "doesn't call itself recursively"

          it 'schedules BuildPositionReportWorker for each position' do
            expect { call_service }.to change(BuildPositionReportWorker.jobs, :size).by(2)
            expect(
              BuildPositionReportWorker.jobs.pluck('args')
            ).to match_array([[position_report_1.id], [position_report_2.id]])
          end
        end

        context 'when report has no :initialized positions' do
          let(:position) { create(:position, portfolio_report:) }
          let!(:position_report) { create(:position_report, position:, status: position_report_status) } # rubocop:disable RSpec/LetSetup

          context 'when existing position reports are in completed or failed status' do # rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/NestedGroups
            let(:position_report_status) { :completed }

            it_behaves_like 'calls itself recursively'
            it_behaves_like 'updates status to', 'completed'

            it "doesn't schedule BuildPositionReportWorker" do
              expect { call_service }.not_to change(BuildPositionReportWorker.jobs, :size)
            end
          end

          context 'when at least one of existing positions is still in process' do # rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/NestedGroups
            let(:position_report_status) { :fees_info_fetching }

            it_behaves_like "doesn't call itself recursively"

            it "doesn't schedule BuildPositionReportWorker" do
              expect { call_service }.not_to change(BuildPositionReportWorker.jobs, :size)
            end
          end
        end
      end
    end
  end
end
