# frozen_string_literal: true

require './spec/spec_helper'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Builders::Position::Events::Collects do
  describe '#call' do
    subject(:call_service) { service.call(position) }

    include_context 'with mocked block_timestamp'
    include_context 'with mocked Coingecko::GetHistoricalPrice'
    include_context 'with mocked positions logs'

    let(:service) { described_class.new }
    let(:position) { create(:position, events: log_1001) }

    it { is_expected.to eq(collects_1001) }
  end
end
