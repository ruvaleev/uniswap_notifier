# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe CheckTicksWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async }

    let(:check_service_double) { instance_double(Positions::CheckByOwnerAddress, call: true) }

    before { allow(Positions::CheckByOwnerAddress).to receive(:new).and_return(check_service_double) }

    it_behaves_like 'sidekiq worker'

    context 'when there are users with telegram_chat_id', testing: :inline do
      let!(:user1) { create(:user, telegram_chat_id: SecureRandom.hex) }
      let!(:user2) { create(:user, telegram_chat_id: SecureRandom.hex) }
      let!(:user3) { create(:user, telegram_chat_id: nil) } # rubocop:disable RSpec/LetSetup

      it 'asynchronously checks every user with telegram_chat_id' do
        perform_worker
        expect(check_service_double).to have_received(:call).exactly(2).times
        expect(Positions::CheckByOwnerAddress).to have_received(:new).with(user1.address, 10)
        expect(Positions::CheckByOwnerAddress).to have_received(:new).with(user2.address, 10)
      end
    end
  end
end
