# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Builders::PortfolioReport::InitialMessage do
  describe '#call' do
    subject(:call_service) { service.call(portfolio_report) }

    let(:service) { described_class.new }
    let(:portfolio_report) { build(:portfolio_report, status:) }

    context 'when portfolio_report has status: :positions_fetching' do
      let(:status) { :positions_fetching }

      it { is_expected.to eq(I18n.t('portfolio_reports.positions_fetching')) }
    end

    context 'when portfolio_report has status: :prices_fetching' do
      let(:status) { :prices_fetching }

      it { is_expected.to eq(I18n.t('portfolio_reports.prices_fetching')) }
    end

    context 'when portfolio_report has status: :events_fetching' do
      let(:status) { :events_fetching }

      it { is_expected.to eq(I18n.t('portfolio_reports.events_fetching')) }
    end

    context 'when portfolio_report has status: :results_analyzing' do
      let(:status) { :results_analyzing }

      it { is_expected.to eq(I18n.t('portfolio_reports.results_analyzing')) }
    end

    context 'when portfolio_report has status: :completed' do
      let(:status) { :completed }

      it { is_expected.to eq(I18n.t('portfolio_reports.completed')) }
    end

    context 'when portfolio_report has status: :failed' do
      let(:portfolio_report) { build(:portfolio_report, status:, error_message:) }
      let(:status) { :failed }
      let(:error_message) { 'Some error' }

      it { is_expected.to eq(I18n.t('portfolio_reports.failed', error_message:)) }
    end
  end
end
