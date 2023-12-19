# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::HoldUsdValue do
  describe '#call' do
    subject(:call_service) { service.call(initial_increase, liquidity_changes, token_0_price, token_1_price) }

    let(:service) { described_class.new }
    let(:initial_increase) { { amount_0: 100, amount_1: 200 } }
    let(:liquidity_changes) { { 1_698_175_159 => -50, 1_700_743_351 => -50 } }
    let(:token_0_price) { 1 }
    let(:token_1_price) { 2 }

    it { is_expected.to eq(125) }

    context 'with positive changes' do
      let(:liquidity_changes) { { 1_698_175_159 => -10, 1_700_743_351 => 100 } }

      it { is_expected.to eq(900) }
    end

    context 'with real data' do
      include_context 'with mocked positions logs'

      let(:initial_increase) { liquidity_increases_1001[0] }

      it { is_expected.to eq(19_522.47) }
    end
  end
end
