# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../concerns/pool_state_shared'

RSpec.describe Positions::UpdatePoolState do
  describe '#call' do
    subject(:call_service) { described_class.new.call(position) }

    let(:position) { create(:position, :filled, coin0:, coin1:) }
    let(:positions_coin0) { position.positions_coins.find_by(number: '0') }
    let(:positions_coin1) { position.positions_coins.find_by(number: '1') }
    let(:coin0) { create(:coin) }
    let(:coin1) { create(:coin) }

    include_context 'with PoolStateResponse'

    before do
      allow(BlockchainDataFetcher::Client).to receive(:pool_state)
        .with(position).and_return(pool_state_response)
    end

    it 'updates current state of provided position positions_coins' do
      expect([positions_coin0, positions_coin1].pluck(:amount).flatten.uniq).to eq([nil])

      call_service

      [[positions_coin0, token0_data], [positions_coin1, token1_data]].each do |record, token_data|
        expect(record.reload).to have_attributes(
          amount: BigDecimal(token_data[:amount]),
          price: BigDecimal(token_data[:price]),
          min_price: BigDecimal(token_data[:minPrice]),
          max_price: BigDecimal(token_data[:maxPrice])
        )
      end
    end
  end
end
