# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::CreateLink do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user_id) }

    let(:user_id) { rand(100) }
    let(:token) { SecureRandom.hex }

    before { allow(SecureRandom).to receive(:hex).and_return(token) }

    it { is_expected.to eq("https://t.me/test_bot_username?start=#{token}") }

    it 'writes user_id under generated token as key' do
      expect { call_service }.to change { RedisService.client.get(token) }.from(nil).to(user_id.to_s)
    end
  end
end
