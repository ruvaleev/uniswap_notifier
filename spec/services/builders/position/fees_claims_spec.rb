# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::FeesClaims do
  describe '#call' do
    subject(:call_service) do
      service.call(collects_1001, initial_increase, liquidity_decreases_1001, liquidity_changes)
    end

    include_context 'with mocked positions logs'

    let(:service) { described_class.new }
    let(:initial_increase) { liquidity_increases_1001[0] }
    let(:liquidity_changes) { { 1_698_175_159 => -50, 1_700_743_351 => -100 } }

    it { is_expected.to eq(fees_claims_1001) }

    it "doesn't mutate incoming objects" do
      expect { call_service }.not_to change { collects_1001 }
    end
  end
end
