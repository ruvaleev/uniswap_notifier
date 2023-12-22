# frozen_string_literal: true

require './spec/spec_helper'
require './spec/models/concerns/errors_shared'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe Reports::Position, type: :model do
  subject(:position) { build(:position) }

  it { is_expected.to belong_to(:portfolio_report) }
  it { is_expected.to have_one(:position_report).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:portfolio_report) }
  it { is_expected.to validate_uniqueness_of(:uniswap_id).scoped_to(:portfolio_report_id) }

  it { is_expected.to delegate_method(:usd_price).to(:portfolio_report) }

  describe '#age_days' do
    subject(:age_days) { position.age_days }

    let(:position) { build(:position, initial_timestamp: age.days.ago) }
    let(:age) { rand(20) }

    it { is_expected.to eq(age.to_i) }

    context "when position doesn't have initial_timestamp yet" do
      let(:position) { build(:position, initial_timestamp: nil) }

      it_behaves_like 'raises proper error', described_class::NoInitialTimestamp
    end
  end

  describe '#claimed_fees_earned' do
    subject(:claimed_fees_earned) { position.claimed_fees_earned }

    let(:position) { build(:position, fees_claims: fees_claims_1001, events:) }
    let(:events) { log_1001 }

    include_context 'with mocked positions logs'

    it { is_expected.to eq(1863.20) }

    context 'when position has no events yet' do
      let(:events) { {} }

      it_behaves_like 'raises proper error', described_class::NoEventsInfo
    end
  end

  describe '#divider_0' do
    subject(:divider_0) { position.divider_0 }

    let(:position) { build(:position, token_0: { 'decimals' => decimals }) }
    let(:decimals) { rand(18) }

    it { is_expected.to eq(10**decimals) }
  end

  describe '#divider_1' do
    subject(:divider_1) { position.divider_1 }

    let(:position) { build(:position, token_1: { 'decimals' => decimals }) }
    let(:decimals) { rand(18) }

    it { is_expected.to eq(10**decimals) }
  end

  describe '#expected_apr' do
    subject(:expected_apr) { position.expected_apr }

    let(:position) { build(:position, hold_usd_value:, fees_claims:, initial_timestamp: 30.days.ago) }
    let(:hold_usd_value) { 20_000 }
    let(:fees_claims) { [] }
    let(:unclaimed_fees_earned) { 400 }

    before do
      allow(position).to receive(:unclaimed_fees_earned).and_return(unclaimed_fees_earned)
    end

    it { is_expected.to eq(24.3333) }

    context 'when position has claimed fees as well' do
      let(:fees_claims) { [{ percent_of_deposit: '0.2082' }, { percent_of_deposit: '0.7038' }] }

      it { is_expected.to eq(35.4293) }
    end

    context 'when position has no hold_usd_value' do
      let(:hold_usd_value) { nil }

      it_behaves_like 'raises proper error', described_class::NoHoldUsdValue
    end
  end

  describe '#impermanent_loss' do
    subject(:impermanent_loss) { position.impermanent_loss }

    let(:position) { build(:position, hold_usd_value:) }
    let(:hold_usd_value) { 1_000 }
    let(:usd_value) { 987.99 }

    before do
      allow(position).to receive(:usd_value).and_return(usd_value)
    end

    it { is_expected.to eq(12.01) }
  end

  describe '#impermanent_loss_percent' do
    subject(:impermanent_loss_percent) { position.impermanent_loss_percent }

    let(:position) { build(:position, hold_usd_value:) }
    let(:hold_usd_value) { 1_000 }
    let(:impermanent_loss) { 40.06 }

    before do
      allow(position).to receive(:impermanent_loss).and_return(impermanent_loss)
    end

    it { is_expected.to eq(4.006) }
  end

  describe '#report' do
    subject(:report) { position.report }

    let(:position) { create(:position) }

    context 'when position has no report yet' do
      it 'creates and returns new report for position' do
        expect { report }.to change(PositionReport, :count).by(1)
        expect(report).to have_attributes(position_id: position.id, status: 'initialized')
      end
    end

    context 'when position already has report' do
      let!(:existing_report) { create(:position_report, position:) }

      it "doesn't create new report and returns existing one" do
        expect { report }.not_to change(PositionReport, :count)
        expect(report).to eq(existing_report)
      end
    end
  end

  shared_examples 'retrurns token attribute' do |token_name, attribute_name|
    let(:position) { build(:position, token_name => token) }
    let(:token) { { attribute_name => value } }
    let(:value) { rand(100) }

    it { is_expected.to eq(value) }
  end

  shared_examples 'retrurns usd price of token attribute' do |token_name, token_attribute|
    let(:position) { build(:position, portfolio_report:, token_name => token) }
    let(:portfolio_report) { build(:portfolio_report, prices:) }
    let(:prices) { { 'ARB' => 1.17 } }
    let(:token) { { symbol: 'ARB', token_attribute => '20' } }

    it { is_expected.to eq(23.4) }
  end

  describe '#token_0_amount' do
    subject(:token_0_amount) { position.token_0_amount }

    it_behaves_like 'retrurns token attribute', :token_0, :amount
  end

  describe '#token_0_fees' do
    subject(:token_0_fees) { position.token_0_fees }

    it_behaves_like 'retrurns token attribute', :token_0, :fees
  end

  describe '#token_0_fees_usd' do
    subject(:token_0_fees_usd) { position.token_0_fees_usd }

    it_behaves_like 'retrurns usd price of token attribute', :token_0, :fees
  end

  describe '#token_0_symbol' do
    subject(:token_0_symbol) { position.token_0_symbol }

    it_behaves_like 'retrurns token attribute', :token_0, :symbol
  end

  describe '#token_0_usd' do
    subject(:token_0_usd) { position.token_0_usd }

    it_behaves_like 'retrurns usd price of token attribute', :token_0, :amount
  end

  describe '#token_1_amount' do
    subject(:token_1_amount) { position.token_1_amount }

    it_behaves_like 'retrurns token attribute', :token_1, :amount
  end

  describe '#token_1_fees' do
    subject(:token_1_fees) { position.token_1_fees }

    it_behaves_like 'retrurns token attribute', :token_1, :fees
  end

  describe '#token_1_fees_usd' do
    subject(:token_1_fees_usd) { position.token_1_fees_usd }

    it_behaves_like 'retrurns usd price of token attribute', :token_1, :fees
  end

  describe '#token_1_symbol' do
    subject(:token_1_symbol) { position.token_1_symbol }

    it_behaves_like 'retrurns token attribute', :token_1, :symbol
  end

  describe '#token_1_usd' do
    subject(:token_1_usd) { position.token_1_usd }

    it_behaves_like 'retrurns usd price of token attribute', :token_1, :amount
  end

  describe '#total_fees_profit_in_usd' do
    subject(:total_fees_profit_in_usd) { position.total_fees_profit_in_usd }

    let(:claimed_fees_earned) { rand(100) }
    let(:unclaimed_fees_earned) { rand(100) }

    before do
      allow(position).to receive(:claimed_fees_earned).and_return(claimed_fees_earned)
      allow(position).to receive(:unclaimed_fees_earned).and_return(unclaimed_fees_earned)
    end

    it { is_expected.to eq(claimed_fees_earned + unclaimed_fees_earned) }
  end

  describe '#unclaimed_fees_earned' do
    subject(:unclaimed_fees_earned) { position.unclaimed_fees_earned }

    let(:position) { build(:position, token_0:, token_1:, portfolio_report:) }
    let(:token_0) { { symbol: 'WETH', fees: '0.1' } }
    let(:token_1) { { symbol: 'ARB', fees: '20' } }
    let(:prices) { { 'WETH' => 2000, 'ARB' => 1.0008 } }
    let(:portfolio_report) { build(:portfolio_report, prices:) }

    context 'when all data exist' do
      it { is_expected.to eq(220.02) }
    end

    context 'when tokens have no fees info' do
      let(:token_1) { { symbol: 'ARB' } }

      it_behaves_like 'raises proper error', described_class::NoFeesInfo
    end

    context 'when portfolio report has no prices info' do
      let(:prices) { { 'WETH' => 2000 } }

      it_behaves_like 'raises proper error', PortfolioReport::NoUsdPricesInfo
    end
  end

  describe '#usd_value' do
    subject(:usd_value) { position.usd_value }

    let(:position) { build(:position, token_0:, token_1:, portfolio_report:) }
    let(:token_0) { { symbol: 'WETH', amount: '0.1' } }
    let(:token_1) { { symbol: 'ARB', amount: '20' } }
    let(:prices) { { 'WETH' => 2000, 'ARB' => 1.0008 } }
    let(:portfolio_report) { build(:portfolio_report, prices:) }

    context 'when all data exist' do
      it { is_expected.to eq(220.02) }
    end

    context 'when tokens have no amount info' do
      let(:token_1) { { symbol: 'ARB' } }

      it_behaves_like 'raises proper error', described_class::NoAmountsInfo
    end

    context 'when portfolio report has no prices info' do
      let(:prices) { { 'WETH' => 2000 } }

      it_behaves_like 'raises proper error', PortfolioReport::NoUsdPricesInfo
    end
  end
end
