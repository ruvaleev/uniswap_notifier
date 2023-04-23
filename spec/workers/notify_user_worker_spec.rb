# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe NotifyUserWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(position.id) }

    let(:position) { create(:position) }
    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }

    it 'pushes job on the queue' do
      expect { perform_worker }.to change(described_class.jobs, :size).by(1)
    end

    it 'creates demo user with appropriate email', testing: :inline do
      allow(TelegramNotifier).to receive(:new).with(position).and_return(telegram_notifier_double)
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end
  end
end
