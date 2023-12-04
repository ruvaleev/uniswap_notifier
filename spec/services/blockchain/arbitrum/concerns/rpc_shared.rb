# frozen_string_literal: true

RSpec.shared_context 'with mocked RPC request' do
  let(:response_body) { File.read(fixture_path) }

  before do
    stub_request(:post, /#{ENV.fetch('ARBITRUM_URL', nil)}/).to_return(
      status: 200,
      body: response_body,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end

RSpec.shared_examples 'raises proper error when RPC request is unsuccessful' do
  context 'when contract returned unsuccessful response' do
    let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/error_32602.json' }
    let(:error_message) { 'invalid argument 0: hex string has length 42, want 40 for common.Address' }

    it 'makes proper request and returns proper response' do
      expect { subject }.to raise_error(IOError, error_message)
    end
  end
end
