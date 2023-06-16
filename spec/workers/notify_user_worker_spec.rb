# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe NotifyUserWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(position.id) }

    let(:position) { create(:position, notification_status:, user:, uniswap_id:) }
    let(:notification_status) { :unnotified }
    let(:user) { create(:user, telegram_chat_id:) }
    let(:telegram_chat_id) { rand(100).to_s }
    let(:uniswap_id) { rand(100) }
    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }

    before do
      allow(TelegramNotifier).to receive(:new)
        .with(telegram_chat_id, uniswap_id).and_return(telegram_notifier_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls TelegramNotifier with proper position', testing: :inline do
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end

    context 'when position is notified already' do
      let(:notification_status) { :notified }

      it "doesn't call TelegramNotifier", testing: :inline do
        perform_worker
        expect(telegram_notifier_double).not_to have_received(:call)
      end
    end
  end
end
