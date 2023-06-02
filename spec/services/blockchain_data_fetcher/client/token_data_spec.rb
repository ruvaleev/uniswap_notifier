# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/client_shared'

RSpec.describe BlockchainDataFetcher::Client do
  describe '.token_data' do
    subject(:token_data) { described_class.token_data(address) }

    include_context 'with grpc stub mocks'

    let(:address) { SecureRandom.hex }
    let(:token_request_double) { instance_double(TokenRequest) }

    before do
      allow(TokenRequest).to receive(:new).with(address:).and_return(token_request_double)
    end

    context 'when server returns proper data' do
      let(:token_response) { TokenResponse.new(**data) }
      let(:data) { { name: 'Tether USD', symbol: 'USDT', decimals: 6 } }

      before do
        allow(stub_double).to receive(:get_token_data).with(token_request_double).and_return(token_response)
      end

      it { is_expected.to eq(token_response) }
    end

    it_behaves_like 'properly returns raised errors', :get_token_data
  end
end
