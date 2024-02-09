# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe NotificationsSetting, type: :model do
  subject(:notifications_setting) { build(:notifications_setting) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:out_of_range) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_uniqueness_of(:user_id) }
end
