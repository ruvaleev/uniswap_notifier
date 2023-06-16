# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::CheckByOwnerAddress do
  describe '#call' do
    subject(:call_service) { described_class.new.call(address, threshold) }

    let(:address) { SecureRandom.hex }
    let(:chat_id) { SecureRandom.hex }
    let(:threshold) { 10 }
    let(:graph_double) { instance_double(Graphs::RevertFinance) }
    let(:positions_tickers_json) do
      JSON.parse(File.read('spec/fixtures/graphs/revert_finance/positions_tickers.json'))
    end
    let(:except_ids) { [] }

    before do
      allow(Graphs::RevertFinance).to receive(:new).and_return(graph_double)
      allow(graph_double).to receive(:positions_tickers)
        .with(address, id_not_in: except_ids).and_return(positions_tickers_json)
    end

    it "sends notifications for positions to rebalance and doesn't change notifications for other positions" do
      expect { call_service }.to change(NotifyOwnerWorker.jobs, :size).by(1)
      expect(NotifyOwnerWorker.jobs.last['args']).to eq([address, '2'])
    end

    context 'when there is no positions for notification with provided threshold' do
      let(:threshold) { 0 }

      it "doesn't send any messages" do
        expect { call_service }.not_to change(NotifyOwnerWorker.jobs, :size)
      end
    end
  end
end
