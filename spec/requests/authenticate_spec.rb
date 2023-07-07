# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'GET /authenticate' do
  subject(:send_request) { get '/authenticate', params, headers }

  let(:params) { { address:, message:, signature:, chain_id: } }
  let(:address) { '0x1542daDDa32ba086434D589a8f005176D6E650B4' }
  let(:message) { '1' }
  let(:signature) do
    '0xd5fb766281af5da544c79e8f1ed81a705e4bea0429a313aeab0648e0f1aeee601cf1e63534da5bf94ecae61bc950d0dd0e03eca85e23c2cb9b4903b4b3ca81da1c' # rubocop:disable Layout/LineLength
  end
  let(:chain_id) { 42_161 }
  let(:headers) { { 'REMOTE_ADDR' => ip_address } }
  let(:ip_address) { "123.45.67.#{rand(100)}" }

  context 'when signature is valid' do
    it 'returns successful response and assigns correct Authorization token' do
      expect { send_request }.to change(Authentication, :count).by(1)
      expect(send_request.status).to eq(200)
      expect(Authentication.last).to have_attributes(
        token: last_response.headers['Authentication'],
        ip_address:
      )
    end

    context 'when there are this is the third authentication of this user already' do
      let(:user) { create(:user, address:) }
      let!(:oldest_authentication) { create(:authentication, user:, last_usage_at: Time.now - 86_400) }
      let!(:newest_authentication) { create(:authentication, user:, last_usage_at: Time.now) }

      it 'removes the oldest authentication' do
        expect { send_request }.not_to change(Authentication, :count)
        expect(Authentication.where(id: oldest_authentication)).to be_none
        expect(Authentication.where(id: newest_authentication)).to be_present
      end
    end
  end

  context 'when signature is invalid' do
    let(:signature) do
      '1xd5fb766281af5da544c79e8f1ed81a705e4bea0429a313aeab0648e0f1aeee601cf1e63534da5bf94ecae61bc950d0dd0e03eca85e23c2cb9b4903b4b3ca81da1c' # rubocop:disable Layout/LineLength
    end

    it 'returns :unauthorized error' do
      expect(send_request.status).to eq(401)
    end
  end
end
