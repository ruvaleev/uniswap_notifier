# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PortfolioReportBuild, type: :model do
  subject(:portfolio_report_build) { build(:portfolio_report_build) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_many(:position_report_builds).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:initial_message_id) }
  it { is_expected.to validate_uniqueness_of(:initial_message_id) }
end
