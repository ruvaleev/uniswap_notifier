# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe CoinGeckoClient do
  describe '#usd_price' do
    subject(:usd_price) { described_class.new.usd_price(ids) }

    let(:ids) { %w[ethereum usd-coin] }

    context 'with successful response from api' do
      let(:response) { File.read('spec/fixtures/coin_gecko_client/simple_price_200.json') }

      before do
        stub_request(
          :get,
          'https://api.coingecko.com/api/v3/simple/price?ids=ethereum%2Cusd-coin&vs_currencies=usd'
        ).to_return(status: 200, body: response, headers: { content_type: 'application/json' })
      end

      it 'returns the price of the given ids according to Coingecko data' do
        expect(usd_price['ethereum']).to eq(2098.15)
        expect(usd_price['usd-coin']).to eq(1.001)
      end
    end

    context 'when rate limit is exceeded' do
      let(:response) { File.read('spec/fixtures/coin_gecko_client/limit_exceeded_429.json') }

      before do
        stub_request(
          :get,
          'https://api.coingecko.com/api/v3/simple/price?ids=ethereum%2Cusd-coin&vs_currencies=usd'
        ).to_return(status: 429, body: response, headers: { content_type: 'application/json' })
      end

      it 'raises CoinGeckoClient::ApiError' do
        expect { usd_price }.to raise_error(CoinGeckoClient::ApiError)
      end
    end
  end
end
