# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::SendMessage do
  describe '#call' do
    subject(:call_service) { described_class.new.call(chat_id:, text:, reply_markup:) }

    let(:chat_id) { rand(100) }
    let(:text) { 'Some text' }
    let(:reply_markup) { Builders::Telegram::ReplyMarkups::Menu.new.call(:en) }
    let(:telegram_send_message_regexp) { %r{https://api\.telegram\.org/bot[^/]+/sendMessage} }
    let(:send_message_response) { File.read('spec/fixtures/telegram/bot_api/send_message/success.json') }

    before do
      stub_request(:post, telegram_send_message_regexp)
        .to_return(status: 200, body: send_message_response)
    end

    it 'sends message to Telegram and returns sent message id' do
      expect(call_service).to eq(2829) # from the fixture
      expect(WebMock).to have_requested(:post, telegram_send_message_regexp).once
    end
  end
end
