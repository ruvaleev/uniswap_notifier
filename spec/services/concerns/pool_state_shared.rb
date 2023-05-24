# frozen_string_literal: true

RSpec.shared_context 'with PoolStateResponse' do
  let(:pool_state_response) { PoolStateResponse.new(token0: token0_response, token1: token1_response) }
  let(:token0_response) { PoolStateResponse::Token.new(**token0_data) }
  let(:token0_data) do
    coin0.slice(:address, :decimals, :symbol, :name).merge(
      amount: '0.256026',
      price: '0.000550193',
      minPrice: '0.0005896208536206515',
      maxPrice: '0.00014745882801726922'
    )
  end
  let(:token1_response) { PoolStateResponse::Token.new(**token1_data) }
  let(:token1_data) do
    coin1.slice(:address, :decimals, :symbol, :name).merge(
      amount: '0.001997438327845076',
      price: '1817.54',
      minPrice: '1696.0051427274943',
      maxPrice: '6781.55396625618'
    )
  end
end
