# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe BlockchainDataFetcher::Client do
  describe '.position_data' do
    subject(:position_data) { described_class.position_data(uniswap_id) }

    let(:uniswap_id) { rand(1_000..5_000) }
    let(:position_request_double) { instance_double(PositionRequest) }
    let(:stub_double) { instance_double(BlockchainDataFetcher::Stub) }

    before do
      allow(PositionRequest).to receive(:new).with(id: uniswap_id).and_return(position_request_double)
      allow(BlockchainDataFetcher::Stub).to receive(:new)
        .with('localhost:50051', :this_channel_is_insecure).and_return(stub_double)
    end

    after { described_class.remove_instance_variable('@stub') }

    context 'when server returns proper data' do
      let(:position_response) { PositionResponse.new(**data) }
      let(:data) do
        {
          token0: '7c234e82f2372c970db47dec14e73dc1',
          token1: 'ea13e907ae659c992e0ec3814f7232c9',
          fee: 3000,
          tickLower: -201_960,
          tickUpper: -188_100,
          liquidity: '1908612923862013',
          poolAddress: '0xC31E54c9a869B9FcBEcc15363CF510d1c41fa440'
        }
      end

      before do
        allow(stub_double).to receive(:get_position_data).with(position_request_double).and_return(position_response)
      end

      it { is_expected.to eq(position_response) }
    end

    context 'when some error raised' do
      let(:error) { GRPC::Unknown.new(error_message) }
      let(:error_message) { 'Something gone wrong' }

      before do
        allow(stub_double).to receive(:get_position_data).with(position_request_double).and_raise(error)
      end

      it 'raises error with proper error message' do
        expect { position_data }.to raise_error(GRPC::Unknown, "2:#{error_message}")
      end
    end
  end
end
