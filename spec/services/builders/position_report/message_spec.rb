# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Builders::PositionReport::Message do
  describe '#call' do
    subject(:call_service) { service.call(position_report) }

    let(:service) { described_class.new }
    let(:position_report) { create(:position_report, position:, status:) }
    let(:position) { create(:position, portfolio_report:, uniswap_id:, **position_params) }
    let(:portfolio_report) { create(:portfolio_report, prices:) }
    let(:prices) { {} }
    let(:uniswap_id) { rand(10) }
    let(:position_params) { {} }

    context 'when position_report has status: :fees_info_fetching' do
      let(:status) { :fees_info_fetching }

      it { is_expected.to eq(I18n.t('position_reports.fees_info_fetching', uniswap_id:)) }
    end

    context 'when position_report has status: :history_analyzing' do
      let(:status) { :history_analyzing }

      it { is_expected.to eq(I18n.t('position_reports.history_analyzing', uniswap_id:)) }
    end

    context 'when position_report has status: :completed' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:status) { :completed }
      let(:position_params) { { hold_usd_value:, token_0:, token_1:, initial_timestamp: age_days.days.ago } }
      let(:token_0) { { symbol: token_0_symbol, amount: token_0_amount, fees: token_0_fees } }
      let(:token_1) { { symbol: token_1_symbol, amount: token_1_amount, fees: token_1_fees } }
      let(:prices) { { token_0_symbol => usd_price_0, token_1_symbol => usd_price_1 } }
      let(:token_0_symbol) { 'WETH' }
      let(:usd_price_0) { 2284.26 }
      let(:token_0_amount) { '0.16504314' }
      let(:token_0_usd) { 377.00 }
      let(:token_0_fees) { '0.00977123' }
      let(:token_0_fees_usd) { 22.32 }
      let(:token_1_symbol) { 'ARB' }
      let(:usd_price_1) { 1.17 }
      let(:token_1_amount) { '8.821728059083442163' }
      let(:token_1_usd) { 10.32 }
      let(:token_1_fees) { '0.178069899668128889' }
      let(:token_1_fees_usd) { 0.21 }
      let(:hold_usd_value) { rand(100) }
      let(:usd_value) { '20151.313636715742' }
      let(:total_fees_profit_in_usd) { 22.52837162241171 }
      let(:unclaimed_fees_earned) { 22.52837162241171 }
      let(:claimed_fees_earned) { 0 }
      let(:expected_apr) { rand(100) }
      let(:impermanent_loss) { rand(0.1..5).round(4) }
      let(:impermanent_loss_percent) { rand(0.1..5).round(4) }
      let(:age_days) { rand(50) }

      before do
        allow(position).to receive(:usd_value).and_return(usd_value)
        allow(position).to receive(:total_fees_profit_in_usd).and_return(total_fees_profit_in_usd)
        allow(position).to receive(:unclaimed_fees_earned).and_return(unclaimed_fees_earned)
        allow(position).to receive(:claimed_fees_earned).and_return(claimed_fees_earned)
        allow(position).to receive(:expected_apr).and_return(expected_apr)
        allow(position).to receive(:impermanent_loss).and_return(impermanent_loss)
        allow(position).to receive(:impermanent_loss_percent).and_return(impermanent_loss_percent)
        allow(position).to receive(:age_days).and_return(age_days)
      end

      it { # rubocop:disable RSpec/ExampleLength
        expect(call_service).to eq(
          I18n.t(
            'position_reports.completed',
            uniswap_id:,
            age_days:,
            token_0_symbol:,
            token_0_amount:,
            token_0_usd:,
            token_0_fees:,
            token_0_fees_usd:,
            token_1_symbol:,
            token_1_amount:,
            token_1_usd:,
            token_1_fees:,
            token_1_fees_usd:,
            usd_value:,
            unclaimed_fees_earned:,
            expected_apr:,
            impermanent_loss_percent:,
            impermanent_loss:
          )
        )
      }
    end

    context 'when position_report has status: :failed' do
      let(:position_report) { build(:position_report, position:, status:, error_message:) }
      let(:status) { :failed }
      let(:error_message) { 'Some error' }

      it { is_expected.to eq(I18n.t('position_reports.failed', error_message:, uniswap_id:)) }
    end
  end
end
