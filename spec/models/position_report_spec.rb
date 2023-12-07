# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PositionReport, type: :model do
  subject(:position_report) { build(:position_report) }

  it { is_expected.to belong_to(:position) }

  it { is_expected.to validate_uniqueness_of(:message_id).allow_nil }
end
