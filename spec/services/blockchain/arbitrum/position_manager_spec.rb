# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/rpc_shared'

RSpec.describe Blockchain::Arbitrum::PositionManager do
  let(:contract) { described_class.new }

  describe '#logs' do
    subject(:logs) { contract.logs(*position_ids) }

    let(:position_ids) { [1000, 1001] }

    include_context 'with mocked positions logs'

    it 'returns properly serialized hash with logs' do
      expect(logs).to eq({ 1000 => log_1000, 1001 => log_1001 })
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end
end
