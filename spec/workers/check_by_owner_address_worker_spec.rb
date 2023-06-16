# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe CheckByOwnerAddressWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(address, threshold) }

    let(:address) { SecureRandom.hex }
    let(:threshold) { 10 }
    let(:check_service_double) { instance_double(Positions::CheckByOwnerAddress, call: true) }

    before { allow(Positions::CheckByOwnerAddress).to receive(:new).and_return(check_service_double) }

    it_behaves_like 'sidekiq worker'

    context 'when there are users with telegram_chat_id', testing: :inline do
      it 'asynchronously checks every user with telegram_chat_id' do
        perform_worker
        expect(check_service_double).to have_received(:call).with(address, threshold).once
      end
    end
  end
end
