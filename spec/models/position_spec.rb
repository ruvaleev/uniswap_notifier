# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Position, type: :model do
  subject(:position) { build(:position) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_many(:positions_coins).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:coins).through(:positions_coins).dependent(:restrict_with_error) }

  it { is_expected.to validate_numericality_of(:rebalance_threshold_percents).is_less_than_or_equal_to(50) }

  it { is_expected.to validate_presence_of(:notification_status) }
  it { is_expected.to validate_presence_of(:rebalance_threshold_percents) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:uniswap_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to validate_uniqueness_of(:uniswap_id).case_insensitive.scoped_to(:user_id) }

  describe '#need_rebalance?' do
    subject(:need_rebalance?) { position.need_rebalance? }

    let(:position) { create(:position, :filled, rebalance_threshold_percents: 10) }
    let(:pos_coins0) { create(:positions_coin, position:, number: 0, **params) }
    let(:pos_coins1) { create(:positions_coin, position:, number: 1) }

    before do
      pos_coins0
      pos_coins1
    end

    context 'when one of positions_coins has too low price' do
      let(:params) { { price: 10, min_price: 9, max_price: 19 } }

      it { is_expected.to be_truthy }
    end

    context 'when one of positions_coins has too high price' do
      let(:params) { { price: 18, min_price: 9, max_price: 19 } }

      it { is_expected.to be_truthy }
    end

    context 'when one of positions_coins has normal price' do
      let(:params) { { price: 10, min_price: 9, max_price: 18 } }

      it { is_expected.to be_falsey }
    end
  end
end
