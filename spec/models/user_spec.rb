# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to have_many(:authentications).dependent(:destroy) }
  it { is_expected.to have_many(:notification_statuses).dependent(:destroy) }
  it { is_expected.to have_many(:portfolio_reports).dependent(:destroy) }
  it { is_expected.to have_many(:wallets).dependent(:destroy) }

  describe '#portfolio_report' do
    subject(:portfolio_report) { user.portfolio_report }

    context 'when user has portfolio_report in closed statuses only' do
      before do
        create(:portfolio_report, user:, status: :completed)
        create(:portfolio_report, user:, status: :failed)
      end

      it 'creates new portfolio report in :positions_fetching status and returns it' do
        expect { portfolio_report }.to change(PortfolioReport, :count).by(1)
        expect(portfolio_report).to be_a(PortfolioReport)
        expect(portfolio_report).to have_attributes(user:, status: 'positions_fetching')
      end
    end

    context 'when user has portfolio_report in one of processing statuses already' do
      let!(:processing_portfolio_report) { create(:portfolio_report, user:, status:) }

      shared_examples "doesn't create new portfolio report, but returns existing one" do
        it "doesn't create new portfolio report, but returns existing one" do
          expect { portfolio_report }.not_to change(PortfolioReport, :count)
          expect(portfolio_report).to eq(processing_portfolio_report)
        end
      end

      context 'when status: :positions_fetching' do
        let(:status) { :positions_fetching }

        it_behaves_like "doesn't create new portfolio report, but returns existing one"
      end

      context 'when status: :prices_fetching' do
        let(:status) { :prices_fetching }

        it_behaves_like "doesn't create new portfolio report, but returns existing one"
      end

      context 'when status: :events_fetching' do
        let(:status) { :events_fetching }

        it_behaves_like "doesn't create new portfolio report, but returns existing one"
      end

      context 'when status: :results_analyzing' do
        let(:status) { :results_analyzing }

        it_behaves_like "doesn't create new portfolio report, but returns existing one"
      end
    end
  end
end
