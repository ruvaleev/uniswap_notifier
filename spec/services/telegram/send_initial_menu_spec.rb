# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::SendInitialMenu do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user.id) }

    let(:user) { create(:user, telegram_chat_id:) }
    let(:telegram_chat_id) { rand(100) }
    let(:send_message_response) { File.read('spec/fixtures/telegram/bot_api/send_message/success.json') }
    let(:pin_message_response) { File.read('spec/fixtures/telegram/bot_api/pin_message/success.json') }
    let(:telegram_send_message_regexp) { %r{https://api\.telegram\.org/bot[^/]+/sendMessage} }
    let(:telegram_pin_message_regexp) { %r{https://api\.telegram\.org/bot[^/]+/pinChatMessage} }

    before do
      stub_request(:post, telegram_send_message_regexp)
        .to_return(status: 200, body: send_message_response)
      stub_request(:post, telegram_pin_message_regexp)
        .to_return(status: 200, body: pin_message_response)
    end

    context 'when user has no :telegram_chat_id' do
      let(:telegram_chat_id) { nil }

      it "doesn't make any request" do
        call_service
        expect(WebMock).not_to have_requested(:post, /\*/)
      end
    end

    context 'when user has :telegram_chat_id' do
      it 'sends message to Telegram' do
        call_service
        expect(WebMock).to have_requested(:post, telegram_send_message_regexp).once
        expect(WebMock).to have_requested(:post, telegram_pin_message_regexp).once
      end

      it "writes sent message id to user's :menu_message_id" do
        expect { call_service }.to change { user.reload.menu_message_id }.from(nil).to(2829) # from the fixture
      end
    end
  end
end
