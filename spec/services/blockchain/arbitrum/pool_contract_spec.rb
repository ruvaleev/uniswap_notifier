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

  describe '#fee_growth_global_0_x128' do
    subject(:fee_growth_global_0_x_128) { contract.fee_growth_global_0_x_128 }

    include_context 'with mocked RPC request' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/fee_growth_global_0_x128/success.json' }
    end

    context 'when contract returned successful response' do
      it 'makes proper request and returns proper response' do
        expect(fee_growth_global_0_x_128).to eq(BigDecimal('16768236117016105549879546996107'))
      end
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end

  describe '#fee_growth_global_1_x128' do
    subject(:fee_growth_global_1_x_128) { contract.fee_growth_global_1_x_128 }

    include_context 'with mocked RPC request' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/fee_growth_global_1_x128/success.json' }
    end

    context 'when contract returned successful response' do
      it 'makes proper request and returns proper response' do
        expect(fee_growth_global_1_x_128).to eq(BigDecimal('2470861406833279021277638089933409415314403'))
      end
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end
end
