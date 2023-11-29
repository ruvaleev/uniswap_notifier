# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Coingecko::GetUsdPrice do
  describe '#call' do
    subject(:call_service) { described_class.new.call(*symbols) }

    let(:symbols) { %i[ARB USDC WETH] }
    let(:response_body) { File.read('spec/fixtures/coingecko/get_usd_price/success.json') }
    let(:status) { 200 }

    before do
      stub_request(:get, /api.coingecko.com/).to_return(
        status:,
        body: response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    context 'when API returned successful response' do
      it 'returns correctly parsed response' do
        expect(call_service).to eq({ 'ARB' => 0.920302, 'USDC' => 0.998581, 'WETH' => 1699.14 })
        expect(call_service[:ARB]).to eq(0.920302)
      end
    end

    context 'when API returned unsuccessful response' do
      let(:response_body) { File.read('spec/fixtures/coingecko/get_usd_price/error.json') }
      let(:status) { 422 }

      it 'raises Coingecko::Error with proper message' do
        expect { call_service }.to raise_error(Coingecko::Error, 'Missing parameter ids')
      end
    end

    context 'when unknown token passed' do
      let(:symbols) { %i[AAA ARB] }

      it 'raises Coingecko::UnknownToken error' do
        expect { call_service }.to raise_error(Coingecko::UnknownToken, 'Unknown token: AAA')
      end
    end
  end
end
