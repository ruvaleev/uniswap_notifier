# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::HandleCallback do
  describe '#call' do
    subject(:call_service) { described_class.new.call(callback_body) }

    let(:callback_body) { JSON.parse(File.read("spec/fixtures/telegram/#{callback_name}.json")) }

    context 'when in body start callback' do
      let(:callback_name) { :start_callback }
      let(:token) { 'token_is_here' }
      let!(:user) { create(:user) }

      context 'when there is :user_id for provided token in cache' do
        before { RedisService.client.set(token, user.id) }

        it 'assigns chat_id to the user' do
          expect { call_service }.to change { user.reload.telegram_chat_id }.from(nil).to('999887755')
        end
      end

      context 'when there is no :user_id for provided token in cache' do
        it "doesn't change user's :telegram_chat_id" do
          expect { call_service }.not_to change { user.reload.telegram_chat_id }
        end
      end
    end

    context 'when there is other test in body' do
      let(:callback_name) { :message_callback }

      it { is_expected.to be_nil }
    end

    context 'when callback_body is empty' do
      let(:callback_body) { {} }

      it { is_expected.to be_nil }
    end
  end
end
