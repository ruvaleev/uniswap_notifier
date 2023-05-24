# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/client_shared'
require_relative '../../concerns/pool_state_shared'

RSpec.describe BlockchainDataFetcher::Client do
  describe '.pool_state' do
    subject(:pool_state) { described_class.pool_state(position) }

    include_context 'with grpc stub mocks'

    let(:position) { create(:position, :filled, coin0:, coin1:) }
    let(:coin0) { create(:coin) }
    let(:coin1) { create(:coin) }
    let(:token0_params) { coin0.slice(:address, :decimals, :symbol, :name) }
    let(:token1_params) { coin1.slice(:address, :decimals, :symbol, :name) }
    let(:token0_request_double) { instance_double(PoolStateRequest::Token) }
    let(:token1_request_double) { instance_double(PoolStateRequest::Token) }
    let(:pool_state_request_double) { instance_double(PoolStateRequest) }
    let(:pool_state_params) do
      {
        poolAddress: position.pool_address,
        chainId: Position::CHAIN_ID,
        token0: token0_request_double,
        token1: token1_request_double,
        fee: position.fee,
        tickLower: position.tick_lower,
        tickUpper: position.tick_upper,
        positionLiquidity: position.liquidity
      }
    end

    before do
      allow(PoolStateRequest::Token).to receive(:new).with(**token0_params).and_return(token0_request_double)
      allow(PoolStateRequest::Token).to receive(:new).with(**token1_params).and_return(token1_request_double)
      allow(PoolStateRequest).to receive(:new).with(**pool_state_params).and_return(pool_state_request_double)
    end

    context 'when server returns proper data' do
      include_context 'with PoolStateResponse'

      before do
        allow(stub_double).to receive(:get_pool_state)
          .with(pool_state_request_double).and_return(pool_state_response)
      end

      it { is_expected.to eq(pool_state_response) }
    end

    it_behaves_like 'properly returns raised errors', :get_pool_state
  end
end
