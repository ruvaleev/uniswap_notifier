# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe NotificationStatus, type: :model do
  subject(:notification_status) { build(:notification_status) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:uniswap_id) }
  it { is_expected.to validate_uniqueness_of(:uniswap_id).case_insensitive.scoped_to(:user_id) }
  it { is_expected.to validate_presence_of(:user_id) }
end
