# frozen_string_literal: true

RSpec.shared_context 'with grpc stub mocks' do
  let(:stub_double) { instance_double(BlockchainDataFetcher::Stub) }

  before do
    allow(BlockchainDataFetcher::Stub).to receive(:new)
      .with('localhost:50051', :this_channel_is_insecure).and_return(stub_double)
  end

  after { described_class.remove_instance_variable('@stub') }
end

RSpec.shared_examples 'properly returns raised errors' do |method_name|
  context 'when some error raised' do
    let(:error) { GRPC::Unknown.new(error_message) }
    let(:error_message) { 'Something gone wrong' }

    before do
      allow(stub_double).to receive(method_name).and_raise(error)
    end

    it 'raises error with proper error message' do
      expect { subject }.to raise_error(GRPC::Unknown, "2:#{error_message}")
    end
  end
end
