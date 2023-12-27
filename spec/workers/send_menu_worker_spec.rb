# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe SendMenuWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(chat_id) }

    let(:chat_id) { rand(100) }
    let(:service_double) { instance_double(Telegram::SendMenu, call: true) }

    before do
      allow(Telegram::SendMenu).to receive(:new).and_return(service_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls Telegram::SendMenu with provided :chat_id', testing: :inline do
      perform_worker
      expect(service_double).to have_received(:call).with(chat_id)
    end
  end
end
