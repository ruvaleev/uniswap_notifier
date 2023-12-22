# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/rpc_shared'

RSpec.describe Blockchain::Arbitrum::PoolContract do
  let(:contract) { described_class.new(address) }
  let(:address) { rand_blockchain_address }

  describe '#ticks' do
    subject(:ticks) { contract.ticks(tick) }

    let(:tick) { 258_420 }

    include_context 'with mocked RPC request' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/ticks/success.json' }
    end

    it 'returns properly initialized Ticker object' do
      expect(ticks).to be_a(Tick)
      expect(ticks.fee_growth_outside_0_x_128).to be_a(BigDecimal)
      expect(ticks.fee_growth_outside_0_x_128).to eq(BigDecimal('14434802355389936311118482405690'))
      expect(ticks.fee_growth_outside_1_x_128).to be_a(BigDecimal)
      expect(ticks.fee_growth_outside_1_x_128).to eq(BigDecimal('2042377118337089894153321452778770940597754'))
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end
end
