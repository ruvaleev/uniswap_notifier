# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PortfolioReport, type: :model do
  subject(:portfolio_report) { build(:portfolio_report) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_many(:positions).class_name('Reports::Position').dependent(:destroy) }

  it { is_expected.to validate_presence_of(:initial_message_id) }
  it { is_expected.to validate_uniqueness_of(:initial_message_id) }

  describe '.in_process' do
    subject(:in_process) { described_class.in_process }

    let!(:initialized_report) { create(:portfolio_report, status: :initialized) }
    let!(:positions_fetched_report) { create(:portfolio_report, status: :positions_fetched) }
    let!(:prices_fetched_report) { create(:portfolio_report, status: :prices_fetched) }
    let!(:completed_report) { create(:portfolio_report, status: :completed) }
    let!(:failed_report) { create(:portfolio_report, status: :failed) }

    it { is_expected.to include(initialized_report, positions_fetched_report, prices_fetched_report) }
    it { is_expected.not_to include(completed_report, failed_report) }
  end
end
