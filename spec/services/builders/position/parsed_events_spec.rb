# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::ParsedEvents do
  describe '#call' do
    subject(:call_service) { service.call(position) }

    let(:service) { described_class.new }
    let(:position) { build(:position, events: log_1001, portfolio_report:, token_0:, token_1:) }
    let(:token_0) { { symbol: 'WETH', decimals: 18 } }
    let(:token_1) { { symbol: 'ARB', decimals: 18 } }
    let(:portfolio_report) { build(:portfolio_report, prices:) }
    let(:prices) { { 'WETH' => 2000, 'ARB' => 1 } }

    include_context 'with mocked block_timestamp'
    include_context 'with mocked Coingecko::GetHistoricalPrice'
    include_context 'with mocked positions logs'

    it 'enriches events with historical prices and fills proper fields in position with results' do
      expect(call_service).to eq(
        {
          collects: collects_1001,
          liquidity_decreases: liquidity_decreases_1001,
          liquidity_increases: liquidity_increases_1001,
          fees_claims: fees_claims_1001,
          liquidity_changes: { 1_698_175_159 => -50, 1_700_743_351 => -50 },
          hold_usd_value: 9775.43
        }
      )
    end

    context 'when position evetns are blank' do
      let(:position) { build(:position) }

      it 'raises proper error' do
        expect { call_service }.to raise_error(described_class::EventsNotFound)
      end
    end
  end
end
