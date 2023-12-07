# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::Delete do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user) }

    let(:user) { build(:user, telegram_chat_id:) }
    let(:telegram_chat_id) { rand(100) }

    it "clears user's :telegram_chat_id field" do
      expect { call_service }.to change(user, :telegram_chat_id).from(telegram_chat_id).to(nil)
    end
  end
end
