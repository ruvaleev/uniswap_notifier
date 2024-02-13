# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'PATCH /notifications_setting' do
  subject(:send_request) { patch '/notifications_setting', params, headers }

  let(:params) { { out_of_range: } }
  let(:out_of_range) { false }
  let(:headers) { { 'Accept' => 'application/json', 'REMOTE_ADDR' => ip_address } }
  let(:ip_address) { "123.45.67.#{rand(100)}" }
  let(:user) { create(:user) }
  let(:token) { SecureRandom.hex }

  before { set_cookie "Authentication=#{token}" }

  context 'when unauthenticated request' do
    it 'returns :unauthorized error' do
      expect(send_request.status).to eq(401)
    end
  end

  context 'when authenticated request' do
    let(:authentication) { create(:authentication, token:, ip_address:, user:) }

    before { authentication }

    it 'returns 200 status' do
      expect(send_request.status).to eq(200)
    end

    it 'updates user notifications_setting with provided params' do
      send_request
      expect(user.notifications_setting.out_of_range).to be_falsy
    end

    context 'when provided params are invalid' do
      let(:out_of_range) { nil }

      it 'returns 422 status' do
        expect(send_request.status).to eq(422)
      end

      it "doesn't create new NotificationsSetting" do
        expect { send_request }.not_to change(NotificationsSetting, :count)
      end
    end
  end
end
