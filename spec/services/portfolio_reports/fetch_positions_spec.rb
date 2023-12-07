# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/concerns/graph_shared'

RSpec.describe PortfolioReports::FetchPositions do
  describe '#call' do
    subject(:call_service) { service.call }

    let(:service) { described_class.new(portfolio_report) }
    let(:portfolio_report) { create(:portfolio_report) }
    let(:wallets) { create_list(:wallet, 2, user: portfolio_report.user) }

    include_context 'with mocked graph positions request'

    context 'when portfolio_report user has multiple wallets' do
      before { wallets }

      it 'fetches positions for every address of portfolio_report user and saves them to the DB' do
        expect { call_service }.to change(portfolio_report.positions, :count).by(2)
        expect(call_service).to match_array(portfolio_report.position_ids)
        expect(api_service_double).to have_received(:positions).with(*wallets.pluck(:address)).once
      end
    end

    context 'when portfolio_report user has no wallets' do
      it "doesn't call API, doesn't create new positions and returns empty array" do
        expect { call_service }.not_to change(portfolio_report.positions, :count)
        expect(call_service).to eq([])
        expect(api_service_double).not_to have_received(:positions)
      end
    end
  end
end
