# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Tick, type: :model do
  let(:tick) { described_class.new(fgo_0_x_128, fgo_1_x_128) }
  let(:fgo_0_x_128) { rand(100) }
  let(:fgo_1_x_128) { rand(100) }

  describe '#fee_growth_outside_0_x_128' do
    subject(:fee_growth_outside_0_x_128) { tick.fee_growth_outside_0_x_128 }

    it { is_expected.to eq(BigDecimal(fgo_0_x_128)) }
  end

  describe '#fee_growth_outside_1_x_128' do
    subject(:fee_growth_outside_1_x_128) { tick.fee_growth_outside_1_x_128 }

    it { is_expected.to eq(BigDecimal(fgo_1_x_128)) }
  end
end
