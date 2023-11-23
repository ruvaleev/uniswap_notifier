# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::Check do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user) }

    let(:user) { build(:user, telegram_chat_id:) }
    let(:telegram_chat_id) { nil }

    context 'when user has :telegram_chat_id' do
      let(:telegram_chat_id) { rand(100) }

      it 'returns proper response with link to the bot' do
        expect(call_service).to eq(
          { connected: true, link: Telegram::BOT_URL }
        )
      end
    end

    context 'when user has no :telegram_chat_id' do
      it 'returns proper response without link to the bot' do
        expect(call_service).to eq(
          { connected: false, link: nil }
        )
      end
    end
  end
end
