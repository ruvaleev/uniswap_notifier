# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Position, type: :model do
  subject(:position) { build(:position) }

  it { is_expected.to belong_to(:user) }

  it {
    expect(position).to belong_to(:coin0)
      .class_name(:Coin).with_foreign_key(:coin0_id).inverse_of(:coin0_positions)
  }

  it {
    expect(position).to belong_to(:coin1)
      .class_name(:Coin).with_foreign_key(:coin1_id).inverse_of(:coin1_positions)
  }

  it { is_expected.to validate_presence_of(:coin0_id) }
  it { is_expected.to validate_presence_of(:coin1_id) }
  it { is_expected.to validate_presence_of(:notification_status) }
  it { is_expected.to validate_presence_of(:rebalance_threshold_percents) }
  it { is_expected.to validate_numericality_of(:rebalance_threshold_percents).is_less_than_or_equal_to(50) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:user_id) }
end
