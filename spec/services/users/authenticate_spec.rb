# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Users::Authenticate do
  describe '#call' do
    subject(:call_service) { described_class.new.call(address, ip_address) }

    let(:address) { SecureRandom.hex }
    let(:ip_address) { "123.45.67.#{rand(100)}" }

    context 'when there is no wallet with provided :address in db' do
      it 'creates new wallet with provided :address' do
        expect { call_service }.to change(Wallet.where(address:), :count).by(1)
      end

      it 'creates new authentication with provided :ip_address for the new user and returns its token' do
        expect { call_service }.to change(Authentication, :count).by(1)
        authentication = Authentication.last
        expect(call_service).to eq(authentication.token)
        expect(authentication.user.wallets.last).to have_attributes(address:)
        expect(authentication.ip_address).to eq(ip_address)
      end
    end

    context 'when there is already user with provided :address in db' do
      let(:wallet) { create(:wallet, address:) }
      let!(:user) { wallet.user }

      it "doesn't create new user" do
        expect { call_service }.not_to change(User, :count)
      end

      it 'creates new authentication with provided :ip_address for the found user and returns its token' do
        expect { call_service }.to change(user.authentications, :count).by(1)
        authentication = user.authentications.last
        expect(call_service).to eq(authentication.token)
        expect(authentication.user.wallets.last.address).to eq(address)
        expect(authentication.ip_address).to eq(ip_address)
      end

      context 'when there are already maximum authentications for the found user' do
        let!(:oldest_authentication) { create(:authentication, user:, last_usage_at: Time.now - 86_400) }
        let!(:newest_authentication) { create(:authentication, user:, last_usage_at: Time.now) }

        it 'destroys the oldest authentication' do
          expect { call_service }.not_to change(Authentication, :count)
          expect(Authentication.where(id: oldest_authentication)).to be_none
          expect(Authentication.where(id: newest_authentication)).to be_present
        end
      end
    end
  end
end
