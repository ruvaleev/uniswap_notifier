# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PositionsCoin, type: :model do
  it { is_expected.to belong_to(:coin) }
  it { is_expected.to belong_to(:position) }

  it { is_expected.to validate_presence_of(:coin_id) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:position_id) }

  context 'with persisted relations' do
    subject(:positions_coin) { create(:positions_coin) }

    it { is_expected.to validate_uniqueness_of(:number).case_insensitive.scoped_to(:position_id) }
  end

  describe '.to_rebalance' do
    subject(:to_rebalance) { described_class.to_rebalance(threshold) }

    let(:threshold) { 10 }
    let(:too_low_price_record) { create(:positions_coin, **too_low_price_params) }
    let(:too_high_price_record) { create(:positions_coin, **too_high_price_params) }
    let(:normal_price_record) { create(:positions_coin, **normal_price_params) }
    let(:too_low_price_params) { { price: 10, min_price: 9, max_price: 19 } }
    let(:too_high_price_params) { { price: 18, min_price: 9, max_price: 19 } }
    let(:normal_price_params) { { price: 10, min_price: 9, max_price: 18 } }

    before do
      too_low_price_record
      too_high_price_record
      normal_price_record
    end

    it { is_expected.to be_an(ActiveRecord::Relation) }
    it { is_expected.to match_array([too_low_price_record, too_high_price_record]) }
  end
end
