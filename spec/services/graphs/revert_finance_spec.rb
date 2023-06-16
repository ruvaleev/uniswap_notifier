# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Graphs::RevertFinance do
  subject(:service) { described_class.new }

  let(:owner_address) { SecureRandom.hex(21) }
  let(:uri) { 'https://api.thegraph.com/subgraphs/name/revert-finance/uniswap-v3-arbitrum' }

  before { stub_request(:post, uri).to_return(body: response_body, status: 200) }

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
