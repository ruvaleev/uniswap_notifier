# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Coins::FindOrCreate do
  describe '#call' do
    subject(:call_service) { described_class.new.call(address) }

    let(:address) { SecureRandom.hex }
    let(:token_response) { TokenResponse.new(**token_data) }
    let(:token_data) { { name: 'Tether USD', symbol: 'USDT', decimals: 6 } }

    before do
      allow(BlockchainDataFetcher::Client).to receive(:token_data).with(address).and_return(token_response)
    end

    context 'when coin with provided address exists already' do
      let!(:existing_coin) { create(:coin, address:) }

      it "doesn't fetch data from blockchain" do
        call_service
        expect(BlockchainDataFetcher::Client).not_to have_received(:token_data)
      end

      it "doesn't create new coin" do
        expect { call_service }.not_to change(Coin, :count)
      end

      it 'returns found coin' do
        expect(call_service).to eq(existing_coin)
      end
    end

    context "when coin with provided address doesn't exist yet" do
      it 'creates new coin' do
        expect { call_service }.to change(Coin, :count).by(1)
      end

      it 'creates coin according to data fetched from blockchain' do
        expect(call_service).to be_a(Coin)
        expect(call_service).to have_attributes(address:, **token_data)
        expect(BlockchainDataFetcher::Client).to have_received(:token_data).once
      end
    end
  end
end
