# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Users::FindOrCreateByAddress do
  describe '#call' do
    subject(:call_service) { described_class.new.call(address) }

    let(:address) { rand_blockchain_address }

    context 'when wallet with the address is in DB already' do
      let!(:wallet) { create(:wallet, address:) }

      it 'returns wallet user' do
        expect { call_service }.not_to change(Wallet, :count)
        expect(call_service).to eq(wallet.user)
      end
    end

    context 'when wallet is not in DB yet' do
      it 'creates wallet and returns its user' do
        expect { call_service }.to change(Wallet, :count).by(1)
        expect(call_service).to eq(Wallet.last.user)
      end
    end
  end
end
