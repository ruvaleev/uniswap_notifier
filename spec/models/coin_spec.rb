# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Coin, type: :model do
  subject(:coin) { build(:coin) }

  it { is_expected.to have_many(:coin0_positions).class_name(:Position).dependent(:destroy) }
  it { is_expected.to have_many(:coin1_positions).class_name(:Position).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_presence_of(:symbol) }
  it { is_expected.to validate_presence_of(:decimals) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:address) }
end
