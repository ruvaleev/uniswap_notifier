# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe TelegramNotifier do
  describe '#call' do
    subject(:call_service) { described_class.new(position).call }

    let(:position) { create(:position, user:, notification_status:) }
    let(:user) { create(:user, telegram_chat_id:) }
    let(:notification_status) { :unnotified }
    let(:telegram_chat_id) { rand(100).to_s }
    let(:tg_bot_client_double) { instance_double(Telegram::Bot::Client, api: tg_bot_api_double) }
    let(:tg_bot_api_double) { double(Telegram::Bot::Api, send_message: true) } # rubocop:disable RSpec/VerifiedDoubles
    let(:alert_message) { "Your position needs rebalancing: https://app.uniswap.org/#/pools/#{position.uniswap_id}" }

    before { described_class.instance_variable_set('@client', tg_bot_client_double) }

    it "sends proper message to position user's chat and updates position :notification_status" do
      expect { call_service }.to change(position.reload, :notification_status).from('unnotified').to('notified')
      expect(tg_bot_api_double).to have_received(:send_message)
        .with(chat_id: telegram_chat_id, text: alert_message).once
    end

    context 'when position :notified already' do
      let(:notification_status) { :notified }

      it "doesn't send any message and doesn't change position#notification_status" do
        expect { call_service }.not_to change(position.reload, :notification_status)
        expect(tg_bot_api_double).not_to have_received(:send_message)
      end
    end
  end
end
