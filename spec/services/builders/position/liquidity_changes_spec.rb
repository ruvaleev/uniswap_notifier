# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::LiquidityChanges do
  describe '#call' do
    subject(:call_service) { service.call(liquidity_increases_1001, liquidity_decreases_1001) }

    let(:service) { described_class.new }

    include_context 'with mocked positions logs'

    it { is_expected.to eq({ 1_698_175_159 => -50, 1_700_743_351 => -50 }) }
  end
end
