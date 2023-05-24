# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe BlockchainDataFetcher::Client do
  describe '.token_data' do
    subject(:token_data) { described_class.token_data(address) }

    let(:address) { SecureRandom.hex }
    let(:token_request_double) { instance_double(TokenRequest) }
    let(:stub_double) { instance_double(BlockchainDataFetcher::Stub) }

    before do
      allow(TokenRequest).to receive(:new).with(address:).and_return(token_request_double)
      allow(BlockchainDataFetcher::Stub).to receive(:new)
        .with('localhost:50051', :this_channel_is_insecure).and_return(stub_double)
    end

    after { described_class.remove_instance_variable('@stub') }

    context 'when server returns proper data' do
      let(:token_response) { TokenResponse.new(**data) }
      let(:data) { { name: 'Tether USD', symbol: 'USDT', decimals: 6 } }

      before do
        allow(stub_double).to receive(:get_token_data).with(token_request_double).and_return(token_response)
      end

      it { is_expected.to eq(token_response) }
    end

    context 'when some error raised' do
      let(:error) { GRPC::Unknown.new(error_message) }
      let(:error_message) { 'Something gone wrong' }

      before do
        allow(stub_double).to receive(:get_token_data).with(token_request_double).and_raise(error)
      end

      it 'raises error with proper error message' do
        expect { token_data }.to raise_error(GRPC::Unknown, "2:#{error_message}")
      end
    end
  end
end
