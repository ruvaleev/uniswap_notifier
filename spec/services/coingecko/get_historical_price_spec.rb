# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Coingecko::GetHistoricalPrice do
  describe '#call' do
    subject(:call_service) { described_class.new.call(symbol, date) }

    let(:symbol) { :WBTC }
    let(:date) { '01-10-2023'.to_date }
    let(:cache_key) { "usd_price_#{symbol}_2023-10-01" }
    let(:response_body) { File.read('spec/fixtures/coingecko/get_historical_price/success.json') }
    let(:status) { 200 }

    before do
      stub_request(:get, /api.coingecko.com/).to_return(
        status:,
        body: response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    context 'when API returned successful response' do
      it 'returns correctly parsed response and puts it to cache' do
        expect(RedisService.client.get(cache_key)).to be_nil
        expect(call_service).to be_a(BigDecimal)
        expect(call_service).to eq(BigDecimal('26969.876144072576'))
        expect(WebMock).to have_requested(:get, /api.coingecko.com/).once
        expect(RedisService.client.get(cache_key)).to eq(call_service.to_s)
      end
    end

    context 'when info is already stored in cache' do
      let(:cached_value) { rand(100).to_s }

      before { RedisService.client.set(cache_key, cached_value) }

      it "doesn't make request but returnes cached value" do
        expect(call_service).to be_a(BigDecimal)
        expect(call_service).to eq(BigDecimal(cached_value))
        expect(WebMock).not_to have_requested(:get, /api.coingecko.com/)
      end
    end

    context 'when API returned unsuccessful response' do
      let(:response_body) { File.read('spec/fixtures/coingecko/get_historical_price/error.json') }
      let(:status) { 404 }

      it 'raises Coingecko::Error with proper message' do
        expect { call_service }.to raise_error(Coingecko::Error, 'coin not found')
      end
    end

    context 'when unknown token passed' do
      let(:symbol) { :AAA }

      it 'raises Coingecko::UnknownToken error' do
        expect { call_service }.to raise_error(Coingecko::UnknownToken, 'Unknown token: AAA')
      end
    end
  end
end
