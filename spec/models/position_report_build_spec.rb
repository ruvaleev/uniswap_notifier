# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PositionReportBuild, type: :model do
  subject(:position_report_build) { build(:position_report_build) }

  it { is_expected.to belong_to(:portfolio_report_build) }

  it { is_expected.to validate_presence_of(:message_id) }
  it { is_expected.to validate_uniqueness_of(:message_id) }
end
