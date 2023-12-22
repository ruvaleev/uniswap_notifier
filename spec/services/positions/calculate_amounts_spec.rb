# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::CalculateAmounts do
  describe '#call' do
    subject(:call_service) { service.call }

    let(:service) { described_class.new(position) }
    let(:position) { build(:position, **position_params) }
    let(:position_params) do
      {
        liquidity: 10_860_507_277_202,
        pool: { 'sqrtPrice' => current_sqrt_price },
        tick_lower: 192_180,
        tick_upper: 193_380,
        token_0: { 'decimals' => 18 },
        token_1: { 'decimals' => 18 }
      }
    end

    context 'when current tick is above the upper tick' do
      let(:current_sqrt_price) { '1906627091097897970122208862883908' }
      let(:amount_0) { BigDecimal('0') }
      let(:amount_1) { BigDecimal('0.009999999999987421') }

      it { is_expected.to eq({ amount_0:, amount_1: }) }
    end

    context 'when current tick is below the lower tick' do
      let(:current_sqrt_price) { '1006627091097897900122208862883908' }
      let(:amount_0) { BigDecimal('0.000000000042470714') }
      let(:amount_1) { BigDecimal('0') }

      it { is_expected.to eq({ amount_0:, amount_1: }) }
    end

    context 'when current tick is in range' do
      let(:current_sqrt_price) { '1206627091097897970122208862883908' }
      let(:amount_0) { BigDecimal('0.000000000026252553') }
      let(:amount_1) { BigDecimal('0.003678088176911105') }

      it { is_expected.to eq({ amount_0:, amount_1: }) }
    end
  end
end
