# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::HoldUsdValue do
  describe '#call' do
    subject(:call_service) { service.call(initial_increase, liquidity_changes) }

    let(:service) { described_class.new }
    let(:initial_increase) do
      {
        amount_0: 100,
        amount_1: 200,
        usd_price_0: 2,
        usd_price_1: 1
      }
    end
    let(:liquidity_changes) { { 1_698_175_159 => -50, 1_700_743_351 => -50 } }

    it { is_expected.to eq(100) }

    context 'with positive changes' do
      let(:liquidity_changes) { { 1_698_175_159 => -10, 1_700_743_351 => 100 } }

      it { is_expected.to eq(720) }
    end

    context 'with real data' do
      include_context 'with mocked positions logs'

      let(:initial_increase) { liquidity_increases_1001[0] }

      it { is_expected.to eq(7770.92) }
    end
  end
end
