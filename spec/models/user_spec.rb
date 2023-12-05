# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to have_many(:authentications).dependent(:destroy) }
  it { is_expected.to have_many(:notification_statuses).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:address) }
end
