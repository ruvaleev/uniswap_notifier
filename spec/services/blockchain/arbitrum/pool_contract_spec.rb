# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Blockchain::Arbitrum::PoolContract do
  shared_context 'with mocked RPC request' do
    let(:response_body) { File.read(fixture_path) }

    before do
      stub_request(:post, /#{ENV.fetch('ARBITRUM_URL', nil)}/).to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end
  end

  shared_examples 'raises proper error when RPC request is unsuccessful' do
    context 'when contract returned unsuccessful response' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/error_32602.json' }
      let(:error_message) { 'invalid argument 0: hex string has length 42, want 40 for common.Address' }

      it 'makes proper request and returns proper response' do
        expect { subject }.to raise_error(IOError, error_message)
      end
    end
  end

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
