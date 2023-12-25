# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe SendInitialMenuWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(user_id) }

    let(:user_id) { rand(100) }
    let(:service_double) { instance_double(Telegram::SendInitialMenu, call: true) }

    before do
      allow(Telegram::SendInitialMenu).to receive(:new).and_return(service_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls Telegram::SendInitialMenu with provided user_id', testing: :inline do
      perform_worker
      expect(service_double).to have_received(:call).with(user_id).once
    end

    context 'when called two times with same arguments', testing: :inline do
      it 'calls proper service only one time' do
        2.times { described_class.perform_async(user_id) }
        expect(service_double).to have_received(:call).once
      end
    end
  end
end
