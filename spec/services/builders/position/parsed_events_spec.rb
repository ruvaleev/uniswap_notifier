# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::ParsedEvents do
  describe '#call' do
    subject(:call_service) { service.call(position) }

    let(:service) { described_class.new }
    let(:position) { create(:position, events: log_1001) }

    include_context 'with mocked block_timestamp'
    include_context 'with mocked Coingecko::GetHistoricalPrice'
    include_context 'with mocked positions logs'

    it 'enriches events with historical prices and fills proper fields in position with results' do
      expect(call_service).to eq(position)
      expect(position.collects.to_json).to eq(collects_1001.to_json)
      expect(position.liquidity_decreases.to_json).to eq(liquidity_decreases_1001.to_json)
      expect(position.liquidity_increases.to_json).to eq(liquidity_increases_1001.to_json)
      expect(position.fees_claims.to_json).to eq(fees_claims_1001.to_json)
      expect(position.liquidity_changes).to eq({ '1698175159' => -50, '1700743351' => -50 })
      expect(position.hold_usd_value).to eq(7770.92)
    end

    context 'when position evetns are blank' do
      let(:position) { build(:position) }

      it 'raises proper error' do
        expect { call_service }.to raise_error(described_class::EventsNotFound)
      end
    end
  end
end
