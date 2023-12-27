# frozen_string_literal: true

require './spec/spec_helper'
require './spec/models/concerns/errors_shared'
require './spec/services/blockchain/arbitrum/concerns/rpc_shared'

RSpec.describe PortfolioReport, type: :model do
  subject(:portfolio_report) { build(:portfolio_report) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_many(:positions).class_name('Reports::Position').dependent(:destroy) }

  it { is_expected.to validate_uniqueness_of(:initial_message_id).allow_nil }
  it { is_expected.to validate_presence_of(:user) }

  describe '#claimed_fees' do
    subject(:claimed_fees) { portfolio_report.claimed_fees }

    include_context 'with mocked positions logs'

    let!(:position_1) { create(:position, portfolio_report:, fees_claims: fees_claims_1, events: log_1001) } # rubocop:disable RSpec/LetSetup
    let!(:position_2) { create(:position, portfolio_report:, fees_claims: fees_claims_2, events: log_1001) } # rubocop:disable RSpec/LetSetup
    let(:fees_claims_1) do
      [
        { 'amount_0' => '1', 'usd_price_0' => '100', 'amount_1' => '0.1', 'usd_price_1' => '2000' },
        { 'amount_0' => '0.2', 'usd_price_0' => '99', 'amount_1' => '0.02', 'usd_price_1' => '2002' }
      ]
    end
    let(:fees_claims_2) do
      [
        { 'amount_0' => '40', 'usd_price_0' => '0.5', 'amount_1' => '1', 'usd_price_1' => '105' }
      ]
    end

    it { is_expected.to eq(484.84) }
  end

  describe '#prices_as_string' do
    subject(:prices_as_string) { portfolio_report.prices_as_string }

    let(:portfolio_report) { build(:portfolio_report, prices:) }
    let(:prices) { { 'WETH' => 2000, 'ARB' => 1.17, 'BTC' => 40_000.145 } }

    it { is_expected.to eq('ARB: $1.17, BTC: $40000.15, WETH: $2000') }
  end

  shared_examples 'sends message and writes its id to a proper field' do |
    id_field, message_builder_service, markup_builder_service = nil
  |
    let(:portfolio_report) { build(:portfolio_report, user:, id_field => message_id) }
    let(:user) { build(:user, telegram_chat_id: chat_id) }
    let(:chat_id) { rand(100) }
    let(:message_id) { rand(100) }
    let(:text) { 'Some text' }
    let(:message_builder_double) { instance_double(message_builder_service, call: text) }
    let(:reply_markup) { markup_builder_service&.new&.call(:en) }
    let(:send_message_service_double) { instance_double(Telegram::Reports::SendOrUpdateMessage, call: response) }
    let(:response) { JSON.parse(File.read('spec/fixtures/telegram/bot_api/send_message/success.json')) }

    before do
      allow(message_builder_service).to receive(:new).and_return(message_builder_double)
      allow(Telegram::Reports::SendOrUpdateMessage).to receive(:new).and_return(send_message_service_double)
    end

    context "when has no #{id_field}" do
      let(:message_id) { nil }

      it "sends message and saves #{id_field} from response" do
        expect do
          subject
        end.to change(portfolio_report, id_field).from(nil).to(2829) # from the fixture
        expect(
          send_message_service_double
        ).to have_received(:call).with(chat_id:, message_id:, text:, reply_markup:).once
      end
    end

    context "when has #{id_field} already" do
      it "sends message and doesn't rewrite #{id_field}" do
        expect { subject }.not_to change(portfolio_report, id_field)
        expect(
          send_message_service_double
        ).to have_received(:call).with(chat_id:, message_id:, text:, reply_markup:).once
      end
    end
  end

  describe '#send_initial_message' do
    subject(:send_initial_message) { portfolio_report.send_initial_message }

    it_behaves_like 'sends message and writes its id to a proper field',
                    :initial_message_id, Builders::PortfolioReport::InitialMessage
  end

  describe '#send_summary_message' do
    subject(:send_summary_message) { portfolio_report.send_summary_message }

    it_behaves_like 'sends message and writes its id to a proper field',
                    :summary_message_id,
                    Builders::PortfolioReport::SummaryMessage,
                    Builders::Telegram::ReplyMarkups::Menu
  end

  shared_context 'with prices and positions' do
    let(:portfolio_report) { create(:portfolio_report, prices:) }
    let(:prices) { { 'ARB' => 1.17, 'BTC' => 40_000, 'WETH' => 1_999 } }
    let!(:position_1) do # rubocop:disable RSpec/LetSetup
      create(
        :position,
        portfolio_report:,
        token_0: { symbol: 'ARB', amount: '10', fees: '1' },
        token_1: { symbol: 'WETH', amount: '0.1', fees: '0.01' }
      )
    end
    let!(:position_2) do # rubocop:disable RSpec/LetSetup
      create(
        :position,
        portfolio_report:,
        token_0: { symbol: 'BTC', amount: '0.001', fees: '0.0001' },
        token_1: { symbol: 'WETH', amount: '1', fees: '0.01' }
      )
    end
  end

  describe '#unclaimed_fees' do
    subject(:unclaimed_fees) { portfolio_report.unclaimed_fees }

    include_context 'with prices and positions'

    it { is_expected.to eq(45.15) }
  end

  describe '#usd_price' do
    subject(:usd_price) { portfolio_report.usd_price(symbol) }

    let(:portfolio_report) { build(:portfolio_report, prices:) }
    let(:prices) { { symbol => price } }
    let(:symbol) { 'WETH' }
    let(:price) { rand(100) }

    context 'when price is existing' do
      it { is_expected.to eq(price) }
    end

    context 'when price is absent' do
      let(:price) { nil }

      it_behaves_like 'raises proper error', described_class::NoUsdPricesInfo
    end
  end

  describe '#usd_value' do
    subject(:usd_value) { portfolio_report.usd_value }

    include_context 'with prices and positions'

    it { is_expected.to eq(2250.6) }
  end

  describe '.in_process' do
    subject(:in_process) { described_class.in_process }

    let!(:positions_fetching_report) { create(:portfolio_report, status: :positions_fetching) }
    let!(:prices_fetching_report) { create(:portfolio_report, status: :prices_fetching) }
    let!(:events_fetching_report) { create(:portfolio_report, status: :events_fetching) }
    let!(:results_analyzing_report) { create(:portfolio_report, status: :results_analyzing) }
    let!(:completed_report) { create(:portfolio_report, status: :completed) }
    let!(:failed_report) { create(:portfolio_report, status: :failed) }
    let(:in_process_reports) do
      [positions_fetching_report, prices_fetching_report, events_fetching_report, results_analyzing_report]
    end

    it { is_expected.to include(*in_process_reports) }
    it { is_expected.not_to include(completed_report, failed_report) }
  end
end
