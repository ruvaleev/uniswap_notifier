# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../concerns/workers_shared_examples'

RSpec.describe PortfolioReports::SendReportWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(portfolio_report_id) }

    let(:portfolio_report_id) { rand(100) }
    let(:portfolio_report_double) { instance_double(PortfolioReport) }

    before do
      allow(PortfolioReport).to receive(:find).with(portfolio_report_id).and_return(portfolio_report_double)
      allow(portfolio_report_double).to receive(:send_message)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls :send_message method on provided portfolio_report', testing: :inline do
      perform_worker
      expect(portfolio_report_double).to have_received(:send_message).once
    end
  end
end
