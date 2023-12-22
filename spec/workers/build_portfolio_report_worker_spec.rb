# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe BuildPortfolioReportWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(user_id) }

    let(:user_id) { user.id }
    let(:user) { create(:user) }
    let(:builder_double) { instance_double(Builders::PortfolioReport, call: true) }
    let(:portfolio_report) { create(:portfolio_report, status: :positions_fetching, user:) }

    before do
      allow(Builders::PortfolioReport).to receive(:new).and_return(builder_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls Builders::PortfolioReport with user portfolio_report', testing: :inline do
      portfolio_report
      perform_worker
      expect(builder_double).to have_received(:call).with(portfolio_report).once
    end

    context 'when there is no user with such id' do
      let(:user_id) { 0 }

      it 'raises ActiveRecord::RecordNotFound error', testing: :inline do
        expect { perform_worker }.to raise_error(ActiveRecord::RecordNotFound)
        expect(builder_double).not_to have_received(:call)
      end
    end

    context 'when called two times with same arguments', testing: :inline do
      it 'calls proper builder only one time' do
        2.times { described_class.perform_async(user_id) }
        expect(builder_double).to have_received(:call).once
      end
    end
  end
end
