# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Currency::ActualizePrices do
  describe '#call' do
    subject(:call_service) { described_class.new.call }

    let!(:btc_currency) { create(:currency, code: :btc) }
    let!(:eth_currency) { create(:currency, code: :eth) }
    let!(:gmx_currency) { create(:currency, code: :gmx) }
    let(:coingecko_response) { File.read('spec/fixtures/coin_gecko/client/simple_price_200.json') }

    before do
      stub_request(:get, %r{https://api.coingecko.com/api/v3/simple/price\?.*})
        .to_return(status: 200, body: coingecko_response, headers: { content_type: 'application/json' })
    end

    it 'calls CoinGecko::Client with proper ids and updates currencies with proper prices' do
      expect { call_service }
        .to change { btc_currency.reload.usd_price }.to(27_573)
        .and change { eth_currency.reload.usd_price }.to(2098.15)
        .and change { gmx_currency.reload.usd_price }.to(74.54)
    end

    it 'writes new data to the db in one query' do
      expect { call_service }.not_to exceed_query_limit(1).with(/UPDATE currencies/)
    end
  end
end
