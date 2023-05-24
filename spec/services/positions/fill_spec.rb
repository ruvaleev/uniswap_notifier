# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::Fill do
  describe '#call' do
    subject(:call_service) { described_class.new.call(position) }

    let(:position) { create(:position) }
    let(:position_response) { PositionResponse.new(**position_data) }
    let(:position_data) do
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
    let(:coin0) { create(:coin, address: position_data[:token0]) }
    let(:coin1) { create(:coin, address: position_data[:token1]) }

    before do
      allow(BlockchainDataFetcher::Client).to receive(:position_data)
        .with(position.uniswap_id).and_return(position_response)
    end

    before(with_coins: true) do
      coin0
      coin1
    end

    context 'when both coins are present in db already', with_coins: true do
      let(:expected_position_attributes) do
        {
          fee: position_data[:fee],
          tick_lower: position_data[:tickLower],
          tick_upper: position_data[:tickUpper],
          liquidity: position_data[:liquidity],
          pool_address: position_data[:poolAddress]
        }
      end

      it "doesn't create new coins" do
        expect { call_service }.not_to change(Coin, :count)
      end

      it 'fetches data from blockchain and writes them to position properly' do
        expect(position.coins.count).to eq(0)
        expect(position).to have_attributes(
          fee: nil, tick_lower: nil, tick_upper: nil, liquidity: nil, pool_address: nil
        )
        call_service
        expect(position.reload.coins).to include(coin0, coin1)
        expect(position).to have_attributes(expected_position_attributes)
      end

      it 'saves :positions_coins under correct numbers' do
        call_service
        expect(position.positions_coins.find_by(coin_id: coin0.id).number).to eq('0')
        expect(position.positions_coins.find_by(coin_id: coin1.id).number).to eq('1')
      end
    end

    context 'when some of tokens are not presented in the db yet' do
      let(:token0_response) { TokenResponse.new(**token0_data) }
      let(:token0_data) { { name: 'Tether USD', symbol: 'USDT', decimals: 6 } }
      let(:token1_response) { TokenResponse.new(**token1_data) }
      let(:token1_data) { { name: 'Wrapped Ether', symbol: 'WETH', decimals: 18 } }

      before do
        allow(BlockchainDataFetcher::Client).to receive(:token_data)
          .with(position_data[:token0]).and_return(token0_response)
        allow(BlockchainDataFetcher::Client).to receive(:token_data)
          .with(position_data[:token1]).and_return(token1_response)
      end

      it 'fetches info about tokens and writes them to the db' do
        expect { call_service }.to change(position.positions_coins, :count).by(2)
                                                                           .and change(Coin, :count).by(2)
        expect(Coin.find_by(address: position_data[:token0])).to have_attributes(token0_data)
        expect(Coin.find_by(address: position_data[:token1])).to have_attributes(token1_data)
      end
    end

    context 'when additional params provided', with_coins: true do
      subject(:call_service) { described_class.new.call(position, additional_params) }

      let(:additional_params) { { status: :active } }

      it 'updates position with provided additional_params as well' do
        expect { call_service }.to change(position.reload, :status).from('pending').to('active')
      end
    end
  end
end
