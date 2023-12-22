# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::Reports::SendOrUpdateMessage do
  describe '#call' do
    subject(:call_service) { described_class.new.call(chat_id:, message_id:, text:) }

    let(:chat_id) { rand(100) }
    let(:message_id) { rand(100) }
    let(:text) { 'Some text' }
    let(:bot_api) { TelegramNotifier.client.api }
    let(:edit_message_text_response) { File.read('spec/fixtures/telegram/bot_api/edit_message_text/success.json') }
    let(:send_message_response) { File.read('spec/fixtures/telegram/bot_api/send_message/success.json') }

    before do
      stub_request(:post, %r{https://api\.telegram\.org/bot[^/]+/editMessageText})
        .to_return(status: 200, body: edit_message_text_response)
      stub_request(:post, %r{https://api\.telegram\.org/bot[^/]+/sendMessage})
        .to_return(status: 200, body: send_message_response)
    end

    context 'when provided both :chat_id and :message_id' do
      it 'edits message with provided :message_id' do
        expect(call_service).to eq(JSON.parse(edit_message_text_response))
      end
    end

    context 'when :message_id is nil' do
      let(:message_id) { nil }

      it 'sends message to chat with provided :chat_id' do
        expect(call_service).to eq(JSON.parse(send_message_response))
      end
    end

    context 'when :chat_id is nil' do
      let(:chat_id) { nil }

      it 'raises proper error' do
        expect { call_service }.to raise_error(described_class::NoChatId)
      end
    end

    context 'when :text is nil' do
      let(:text) { nil }

      it 'raises proper error' do
        expect { call_service }.to raise_error(described_class::NoText)
      end
    end

    context 'when api returned error' do
      let(:error_response) { File.read("spec/fixtures/telegram/bot_api/edit_message_text/#{fixture_name}.json") }

      before do
        stub_request(:post, %r{https://api\.telegram\.org/bot[^/]+/editMessageText})
          .to_return(status: 400, body: error_response)
      end

      context "when error is about 'message is not modified'" do
        let(:fixture_name) { 'error_message_not_modified' }

        it "doesn't raise any error" do
          expect { call_service }.not_to raise_error
        end
      end

      context 'when error is about anything else' do
        let(:fixture_name) { 'error_message_text_is_empty' }

        it 'raises error with proper message' do
          expect { call_service }.to raise_error(Telegram::Bot::Exceptions::ResponseError)
        end
      end
    end
  end
end
