# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::CreateLink do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user_id) }

    let(:user_id) { rand(100) }
    let(:token) { SecureRandom.hex }
    let(:expected_result) do
      {
        link: "https://t.me/test_bot_username?start=#{token}",
        expires_in_seconds: described_class::TIMEOUT_SECONDS
      }
    end

    before { allow(SecureRandom).to receive(:hex).and_return(token) }

    it { is_expected.to eq(expected_result) }

    it 'writes user_id under generated token as key' do
      expect { call_service }.to change { RedisService.client.get(token) }.from(nil).to(user_id.to_s)
    end
  end
end
