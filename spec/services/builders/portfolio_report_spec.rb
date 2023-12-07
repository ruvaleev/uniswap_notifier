# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/concerns/graph_shared'

RSpec.describe Builders::PortfolioReport do
  describe '#call' do
    subject(:call_service) { service.call(portfolio_report) }

    let(:service) { described_class.new }
    let(:portfolio_report) { create(:portfolio_report, user:, status:) }
    let(:user) { create(:user) }
    let(:wallet) { create(:wallet, user:) }

    before do
      wallet
      call_count = 0
      allow(service).to receive(:call).and_wrap_original do |original_method, *args|
        call_count += 1
        call_count == 1 ? original_method.call(*args) : true
      end
    end

    include_context 'with mocked graph positions request'

    shared_examples 'sends report' do
      before { allow(portfolio_report).to receive(:send_message) }

      it 'sends report' do
        call_service
        expect(portfolio_report).to have_received(:send_message).once
      end
    end

    shared_examples "doesn't call itself recursively" do
      it "doesn't use :call method after initial call" do
        call_service
        expect(service).to have_received(:call).once
      end
    end

    shared_examples 'calls itself recursively' do
      it 'uses :call method again after initial call' do
        call_service
        expect(service).to have_received(:call).twice
      end
    end

    shared_examples 'updates status to' do |new_status|
      it "updates portfolio status to '#{new_status}'" do
        expect { call_service }.to change(portfolio_report, :status).to(new_status)
      end
    end

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

      context 'when status: :prices_fetched', :multithreaded do
        let(:status) { :prices_fetched }
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
