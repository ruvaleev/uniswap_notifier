# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Builders::PortfolioReport::SummaryMessage do
  describe '#call' do
    subject(:call_service) { service.call(portfolio_report) }

    let(:service) { described_class.new }
    let(:portfolio_report) { build(:portfolio_report) }

    let(:claimed_fees) { rand(100) }
    let(:unclaimed_fees) { rand(100) }
    let(:usd_value) { rand(100) }
    let(:total_fees) { claimed_fees + unclaimed_fees }

    before do
      allow(portfolio_report).to receive(:claimed_fees).and_return(claimed_fees)
      allow(portfolio_report).to receive(:unclaimed_fees).and_return(unclaimed_fees)
      allow(portfolio_report).to receive(:usd_value).and_return(usd_value)
    end

    it do
      expect(call_service).to eq(
        I18n.t('portfolio_reports.summary_message', claimed_fees:, unclaimed_fees:, usd_value:, total_fees:)
      )
    end
  end
end
