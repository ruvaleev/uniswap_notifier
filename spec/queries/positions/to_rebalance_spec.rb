# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Queries::Positions::ToRebalance do
  describe '.call' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:call_query) { described_class.new(relation).call }

    let(:relation) { Position }
    let(:too_low_position) { create(:position, :filled, rebalance_threshold_percents: 10) }
    let(:too_low_pos_coins0) { create(:positions_coin, position: too_low_position, number: 0, **too_low_params) }
    let(:too_low_pos_coins1) { create(:positions_coin, position: too_low_position, number: 1) }

    let(:too_high_position) { create(:position, :filled, rebalance_threshold_percents: 10) }
    let(:too_high_pos_coins0) { create(:positions_coin, position: too_high_position, number: 0) }
    let(:too_high_pos_coins1) { create(:positions_coin, position: too_high_position, number: 1, **too_high_params) }

    let(:normal_position) { create(:position, :filled, rebalance_threshold_percents: 10) }
    let(:normal_pos_coins0) { create(:positions_coin, position: normal_position, number: 0, **normal_params) }
    let(:normal_pos_coins1) { create(:positions_coin, position: normal_position, number: 1, **normal_params) }

    let(:too_low_params) { { price: 10, min_price: 9, max_price: 19 } }
    let(:too_high_params) { { price: 18, min_price: 9, max_price: 19 } }
    let(:normal_params) { { price: 10, min_price: 9, max_price: 18 } }

    before do
      too_low_pos_coins0
      too_low_pos_coins1
      too_high_pos_coins0
      too_high_pos_coins1
      normal_pos_coins0
      normal_pos_coins1
    end

    it 'returns ActiveRecord::Relation with target records only' do
      expect(call_query).to be_an(ActiveRecord::Relation)
      expect(call_query).to match_array([too_low_position, too_high_position])
      expect(call_query).not_to include(normal_position)
    end
  end
end
