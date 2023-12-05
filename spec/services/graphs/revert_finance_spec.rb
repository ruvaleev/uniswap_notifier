# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Graphs::RevertFinance do
  subject(:service) { described_class.new }

  let(:owner_address) { SecureRandom.hex(21) }
  let(:uri) { 'https://api.thegraph.com/subgraphs/name/revert-finance/uniswap-v3-arbitrum' }
  let(:response_status) { 200 }

  before { stub_request(:post, uri).to_return(body: response_body, status: response_status) }

  describe '#pool' do
    subject(:pool) { service.pool(id, block_number) }

    let(:id) { '0xc6f780497a95e246eb9449f5e4770916dcd6396a' }
    let(:block_number) { 132_099_846 }
    let(:response_body) { File.read('spec/fixtures/graphs/revert_finance/pool/200_success.json') }

    context 'when response has 200 status code' do
      it 'calls the correct API with the correct body and returns the correct response' do
        expect(pool).to eq(JSON.parse(response_body)['data']['pools'].first)
        expect(
          a_request(:post, uri).with do |req|
            req.body.include?(id) && req.body.include?(described_class::POOLS_FIELDS)
          end
        ).to have_been_made.once
      end

      context 'when response body has an error' do
        let(:response_body) { File.read('spec/fixtures/graphs/revert_finance/pool/200_error.json') }

        it 'raises proper error' do
          expect { pool }.to raise_error(described_class::ApiError, JSON.parse(response_body)['errors'].to_json)
        end
      end
    end

    context 'when response has error status code' do
      let(:response_status) { 400 }
      let(:response_body) { File.read('spec/fixtures/graphs/revert_finance/pool/400_error.json') }

      it 'raises proper error' do
        expect { pool }.to raise_error(described_class::ApiError, response_body)
      end
    end
  end

  describe '#positions' do
    subject(:positions) { service.positions(owner_address) }

    let(:response_body) { File.read('spec/fixtures/graphs/revert_finance/positions.json') }

    it 'calls the correct API with the correct body and returns the correct response' do
      expect(positions).to eq(JSON.parse(response_body))
      expect(
        a_request(:post, uri).with do |req|
          req.body.include?(owner_address) && req.body.include?(described_class::POSITIONS_FIELDS)
        end
      ).to have_been_made.once
    end
  end

  describe '#positions_tickers' do
    subject(:positions_tickers) { service.positions_tickers(owner_address) }

    let(:response_body) { File.read('spec/fixtures/graphs/revert_finance/positions_tickers.json') }

    it 'calls the correct API with the correct body and returns the correct response' do
      expect(positions_tickers).to eq(JSON.parse(response_body))
      expect(
        a_request(:post, uri).with do |req|
          req.body.include?(owner_address) &&
            req.body.include?(described_class::POSITIONS_TICKERS_FIELDS) &&
            !req.body.include?('id_not_in:')
        end
      ).to have_been_made.once
    end

    context 'when :id_not_in parameter has been provided' do
      subject(:positions_tickers) { service.positions_tickers(owner_address, id_not_in: ids_array) }

      let(:ids_array) { [100, 200, 300] }

      it 'calls the correct API with the correct body and returns the correct response' do
        expect(positions_tickers).to eq(JSON.parse(response_body))
        expect(
          a_request(:post, uri).with do |req|
            req.body.include?(owner_address) &&
              req.body.include?(described_class::POSITIONS_TICKERS_FIELDS) &&
              req.body.include?('id_not_in: [100, 200, 300]')
          end
        ).to have_been_made.once
      end
    end
  end
end
