# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'GET /check_telegram' do
  subject(:send_request) { get '/check_telegram', {}, headers }

  let(:headers) { { 'Accept' => 'application/json', 'REMOTE_ADDR' => ip_address } }
  let(:token) { SecureRandom.hex }
  let(:ip_address) { "123.45.67.#{rand(100)}" }
  let(:telegram_chat_id) { nil }
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

    context 'when user has :telegram_chat_id' do
      let(:telegram_chat_id) { rand(100) }

      it 'returns 200 status with {connected: true} in body' do
        expect(send_request.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq({ 'connected' => true })
      end
    end

    context 'when user has no :telegram_chat_id' do
      it 'returns 200 status with {connected: false} in body' do
        expect(send_request.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq({ 'connected' => false })
      end
    end
  end
end
