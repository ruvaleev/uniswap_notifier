# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PositionReport, type: :model do
  subject(:position_report) { build(:position_report) }

  it { is_expected.to belong_to(:position) }

  it { is_expected.to validate_uniqueness_of(:message_id).allow_nil }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to validate_uniqueness_of(:position) }

  describe '#send_message' do
    subject(:send_message) { position_report.send_message }

    let(:position_report) { create(:position_report, message_id:, position:) }
    let(:position) { build(:position, portfolio_report:) }
    let(:portfolio_report) { build(:portfolio_report, user:) }
    let(:user) { build(:user, telegram_chat_id: chat_id) }
    let(:chat_id) { rand(100) }
    let(:message_id) { rand(100) }
    let(:text) { 'Some text' }
    let(:message_builder_double) { instance_double(Builders::PositionReport::Message, call: text) }
    let(:send_message_service_double) { instance_double(Telegram::Reports::SendOrUpdateMessage, call: response) }
    let(:response) { JSON.parse(File.read('spec/fixtures/telegram/bot_api/send_message/success.json')) }

    before do
      allow(Builders::PositionReport::Message).to receive(:new).and_return(message_builder_double)
      allow(Telegram::Reports::SendOrUpdateMessage).to receive(:new).and_return(send_message_service_double)
    end

    context 'when has no :message_id' do
      let(:message_id) { nil }

      it 'sends message and saves :message_id from response' do
        expect { send_message }.to change(position_report, :message_id).from(nil).to(2829) # from the fixture
        expect(send_message_service_double).to have_received(:call).with(chat_id:, message_id:, text:).once
      end
    end

    context 'when has :message_id already' do
      it "sends message and doesn't rewrite :message_id" do
        expect { send_message }.not_to change(position_report, :message_id)
        expect(send_message_service_double).to have_received(:call).with(chat_id:, message_id:, text:).once
      end
    end
  end

  describe '.in_process' do
    subject(:in_process) { described_class.in_process }

    let!(:initialized_report) { create(:position_report, status: :initialized) }
    let!(:fees_info_fetching_report) { create(:position_report, status: :fees_info_fetching) }
    let!(:history_analyzing_report) { create(:position_report, status: :history_analyzing) }
    let!(:completed_report) { create(:portfolio_report, status: :completed) }
    let!(:failed_report) { create(:portfolio_report, status: :failed) }

    it { is_expected.to include(fees_info_fetching_report, history_analyzing_report) }
    it { is_expected.not_to include(initialized_report, completed_report, failed_report) }
  end

  describe '.initialzied' do
    subject(:initialized) { described_class.initialized }

    let!(:initialized_report) { create(:position_report, status: :initialized) }
    let!(:fees_info_fetching_report) { create(:position_report, status: :fees_info_fetching) }
    let!(:history_analyzing_report) { create(:position_report, status: :history_analyzing) }
    let!(:completed_report) { create(:position_report, status: :completed) }
    let!(:failed_report) { create(:position_report, status: :failed) }
    let(:not_initialized_reports) do
      [fees_info_fetching_report, history_analyzing_report, completed_report, failed_report]
    end

    it { is_expected.to include(initialized_report) }
    it { is_expected.not_to include(*not_initialized_reports) }
  end
end
