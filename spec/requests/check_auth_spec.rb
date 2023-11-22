# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'GET /check_auth' do
  subject(:send_request) { get '/check_auth', {}, headers }

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

    it 'returns 200 status' do
      expect(send_request.status).to eq(200)
    end
  end
end
