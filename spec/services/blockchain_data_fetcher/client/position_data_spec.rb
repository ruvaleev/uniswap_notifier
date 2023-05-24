# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/client_shared'

RSpec.describe BlockchainDataFetcher::Client do
  describe '.position_data' do
    subject(:position_data) { described_class.position_data(uniswap_id) }

    include_context 'with grpc stub mocks'

    let(:uniswap_id) { rand(1_000..5_000) }
    let(:position_request_double) { instance_double(PositionRequest) }

    before do
      allow(PositionRequest).to receive(:new).with(id: uniswap_id).and_return(position_request_double)
    end

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

    it_behaves_like 'properly returns raised errors', :get_position_data
  end
end
