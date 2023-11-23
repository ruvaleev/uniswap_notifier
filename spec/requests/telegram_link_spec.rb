# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'GET /telegram_link' do
  subject(:send_request) { get '/telegram_link', {}, headers }

  let(:headers) { { 'Accept' => 'application/json', 'REMOTE_ADDR' => ip_address } }
  let(:token) { SecureRandom.hex }
  let(:ip_address) { "123.45.67.#{rand(100)}" }

  before { set_cookie "Authentication=#{token}" }

  context 'when unauthenticated request' do
    it 'returns :unauthorized error' do
      expect(send_request.status).to eq(401)
    end
  end

  context 'when authenticated request' do
    let(:authentication) { create(:authentication, token:, ip_address:) }

    before { authentication }

    it 'returns 200 status and newly generated link with correct token' do
      expect(send_request.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['link']).to start_with('https://t.me/')
      expect(response_body['expires_in_seconds']).to eq(Telegram::CreateLink::TIMEOUT_SECONDS)

      token = response_body['link'].split('=').last
      expect(RedisService.client.get(token)).to eq(authentication.user_id.to_s)
    end
  end
end
