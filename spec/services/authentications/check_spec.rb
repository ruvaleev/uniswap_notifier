# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Authentications::Check do
  describe '#call' do
    subject(:call_service) { described_class.new.call(token, ip_address) }

    let(:token) { SecureRandom.hex }
    let(:ip_address) { "223.45.67.#{rand(100)}" }

    context 'when there is no authentication in DB with provided :token' do
      it 'raises NotFound error' do
        expect { call_service }.to raise_error(Authentications::NotFound)
      end
    end

    context 'when there is authentication with provided :token but with different :ip_address' do
      let(:authentication) { create(:authentication, token:) }

      before { authentication }

      it 'raises NotFound error' do
        expect { call_service }.to raise_error(Authentications::NotFound)
      end
    end

    context 'when there is authentication with provided :token and provided :ip_address' do
      let!(:authentication) { create(:authentication, token:, ip_address:) }

      it 'returns found authentication user' do
        expect(call_service).to eq(authentication.user)
      end
    end
  end
end
