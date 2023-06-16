# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe TelegramNotifier do
  describe '#call' do
    subject(:call_service) { described_class.new(telegram_chat_id, uniswap_id).call }

    let(:telegram_chat_id) { rand(100).to_s }
    let(:uniswap_id) { rand(100).to_s }
    let(:tg_bot_client_double) { instance_double(Telegram::Bot::Client, api: tg_bot_api_double) }
    let(:tg_bot_api_double) { double(Telegram::Bot::Api, send_message: true) } # rubocop:disable RSpec/VerifiedDoubles
    let(:alert_message) { "Your position needs rebalancing: https://app.uniswap.org/#/pools/#{uniswap_id}" }

    before { described_class.instance_variable_set('@client', tg_bot_client_double) }

    it 'sends proper message to provided telegram_chat_id' do
      call_service
      expect(tg_bot_api_double).to have_received(:send_message)
        .with(chat_id: telegram_chat_id, text: alert_message).once
    end
  end
end
