# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Wallet, type: :model do
  subject(:wallet) { build(:wallet) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:address) }
end
