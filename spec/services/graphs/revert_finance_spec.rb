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
      expect(service.positions(owner_address)).to eq(JSON.parse(response_body))
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
      expect(service.positions_tickers(owner_address)).to eq(JSON.parse(response_body))
      expect(
        a_request(:post, uri).with do |req|
          req.body.include?(owner_address) && req.body.include?(described_class::POSITIONS_TICKERS_FIELDS)
        end
      ).to have_been_made.once
    end
  end
end
