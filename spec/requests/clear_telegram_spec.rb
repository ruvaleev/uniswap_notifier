# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'PATCH /clear_telegram' do
  subject(:send_request) { patch '/clear_telegram', {}, headers }

  let(:headers) { { 'Accept' => 'application/json', 'REMOTE_ADDR' => ip_address } }
  let(:token) { SecureRandom.hex }
  let(:ip_address) { "123.45.67.#{rand(100)}" }
  let(:telegram_chat_id) { rand(100) }
  let(:user) { create(:user, telegram_chat_id:) }

  before { set_cookie "Authentication=#{token}" }

  context 'when unauthenticated request' do
    it 'returns :unauthorized error' do
      expect(send_request.status).to eq(401)
    end
  end

  context 'when authenticated request' do
    let(:authentication) { create(:authentication, token:, ip_address:, user:) }

    before { authentication }

    it 'clears :telegram_chat_id for current user returns 204 status' do
      expect { send_request }.to change { user.reload.telegram_chat_id }.to(nil)
      expect(last_response.status).to eq(204)
    end
  end
end
