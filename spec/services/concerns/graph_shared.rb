# frozen_string_literal: true

RSpec.shared_context 'with mocked graph positions request' do
  let(:api_service_double) { instance_double(Graphs::RevertFinance) }
  let(:positions_response) { JSON.parse(File.read('spec/fixtures/graphs/revert_finance/positions.json')) }

  before do
    allow(Graphs::RevertFinance).to receive(:new).and_return(api_service_double)
    allow(api_service_double).to receive(:positions).and_return(positions_response)
  end
end
