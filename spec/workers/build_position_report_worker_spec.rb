# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe BuildPositionReportWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(report_id) }

    let(:report_id) { report.id }
    let(:report) { create(:position_report) }
    let(:builder_double) { instance_double(Builders::PositionReport, call: true) }

    before do
      allow(Builders::PositionReport).to receive(:new).and_return(builder_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls Builders::PositionReport with user portfolio_report', testing: :inline do
      perform_worker
      expect(builder_double).to have_received(:call).with(report).once
    end
  end
end
