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
end
