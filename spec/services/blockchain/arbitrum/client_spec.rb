# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/rpc_shared'

RSpec.describe Blockchain::Arbitrum::Client do
  describe '.block_timestamp' do
    subject(:block_timestamp) { described_class.block_timestamp(block_number) }

    let(:block_number) { 153_271_683 }
    let(:cache_key) { 'timestamp_of_153271683' }

    include_context 'with mocked RPC request' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/client/block_timestamp/success.json' }
    end

    it "returns provided block's timestamp and writes it to cache" do
      expect(block_timestamp).to eq(1_700_743_351)
      expect(RedisService.client.get(cache_key)).to eq('1700743351')
    end

    context 'when timestamp is in cache already' do
      let(:cached_value) { '1700743350' }

      before { RedisService.client.set(cache_key, cached_value) }

      it "doesn't make request and returns cached value" do
        expect(block_timestamp).to eq(1_700_743_350)
        expect(WebMock).not_to have_requested(:post, /#{rpc_url}/)
      end
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end
end
