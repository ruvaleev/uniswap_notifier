# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Position, type: :model do
  subject(:position) { build(:position) }

  it { is_expected.to belong_to(:user) }

  it {
    expect(position).to belong_to(:from_currency)
      .class_name(:Currency).with_foreign_key(:from_currency_id).inverse_of(:from_positions)
  }

  it {
    expect(position).to belong_to(:to_currency)
      .class_name(:Currency).with_foreign_key(:to_currency_id).inverse_of(:to_positions)
  }

  it { is_expected.to validate_presence_of(:from_currency_id) }
  it { is_expected.to validate_presence_of(:max_price) }
  it { is_expected.to validate_presence_of(:min_price) }
  it { is_expected.to validate_presence_of(:notification_status) }
  it { is_expected.to validate_presence_of(:rebalance_threshold_percents) }
  it { is_expected.to validate_numericality_of(:rebalance_threshold_percents).is_less_than_or_equal_to(50) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:to_currency_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  describe '.to_rebalance' do
    subject(:to_rebalance) { described_class.to_rebalance }

    let(:currency1) { create(:currency, usd_price: 10) }
    let(:currency2) { create(:currency, usd_price: 20) }
    let(:currency_with_unknown_price) { create(:currency, usd_price: nil) }
    let(:common_position_params) do
      { rebalance_threshold_percents: 10, from_currency: currency1, to_currency: currency2 }
    end
    let!(:object_with_too_low_price) { create(:position, **common_position_params, min_price: 0.49, max_price: 0.59) }
    let!(:object_with_too_high_price) do
      create(:position, **common_position_params, min_price: 0.455, max_price: 0.505)
    end
    let(:object_with_normal_price) { create(:position, **common_position_params, min_price: 0.489, max_price: 0.51) }
    let(:unknown_price_params) { common_position_params.merge(to_currency: currency_with_unknown_price) }
    let(:object_with_unknown_price) { create(:position, **unknown_price_params, min_price: 0.49, max_price: 0.59) }

    before do
      object_with_normal_price
      object_with_unknown_price
    end

    it { is_expected.to be_an(ActiveRecord::Relation) }
    it { is_expected.to match_array([object_with_too_low_price, object_with_too_high_price]) }
  end

  describe '#current_position_price' do
    subject(:current_position_price) { position.current_position_price }

    let(:position) { build(:position, from_currency:, to_currency:) }
    let(:from_currency) { build(:currency, usd_price: 45) }
    let(:to_currency) { build(:currency, usd_price: 100) }

    it { is_expected.to eq(0.45) }
  end
end
