# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::SendSupportContact do
  describe '#call' do
    subject(:call_service) { described_class.new.call(chat_id) }

    let(:chat_id) { rand(100) }
    let(:text) { "@#{ENV.fetch('TELEGRAM_SUPPORT_USERNAME', nil)}" }
    let(:send_message_double) { instance_double(Telegram::SendMessage, call: 2829) }

    before do
      allow(Telegram::SendMessage).to receive(:new).and_return(send_message_double)
    end

    it 'sends message with current support manager' do
      call_service
      expect(send_message_double).to have_received(:call).with(chat_id:, text:).once
    end
  end
end
