# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Position, type: :model do
  subject(:position) { build(:position) }

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

  describe '.to_rebalance' do
    subject(:to_rebalance) { described_class.to_rebalance }

    let(:currency1) { create(:currency, usd_price: 10) }
    let(:currency2) { create(:currency, usd_price: 20) }
    let(:common_position_params) do
      { rebalance_threshold_percents: 10, from_currency: currency1, to_currency: currency2 }
    end
    let!(:object_with_too_low_price) { create(:position, **common_position_params, min_price: 0.45, max_price: 0.6) }
    let!(:object_with_too_high_price) { create(:position, **common_position_params, min_price: 0.35, max_price: 0.55) }
    let(:object_with_normal_price) { create(:position, **common_position_params, min_price: 0.449, max_price: 0.551) }

    before { object_with_normal_price }

    it { is_expected.to match_array([object_with_too_low_price, object_with_too_high_price]) }
  end
end
