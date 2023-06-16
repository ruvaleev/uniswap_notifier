# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe NotifyOwnerWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(address, uniswap_id) }

    let(:user) { create(:user, telegram_chat_id: chat_id) }
    let(:address) { user.address }
    let(:chat_id) { rand(100).to_s }
    let(:uniswap_id) { rand(100) }
    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }

    before { allow(TelegramNotifier).to receive(:new).with(chat_id, uniswap_id).and_return(telegram_notifier_double) }

    it_behaves_like 'sidekiq worker'

    it 'calls TelegramNotifier with proper params', testing: :inline do
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end

    context 'when there is not NotificationStatus for position yet', testing: :inline do
      it 'creates NotificationStatus and moves it to :notified status' do
        expect { perform_worker }.to change(NotificationStatus, :count).by(1)
        expect(NotificationStatus.last).to have_attributes(
          user_id: user.id, uniswap_id:, status: 'notified'
        )
      end
    end

    context 'when there is existing NotificationStatus for position already', testing: :inline do
      let(:notification_status) { create(:notification_status, uniswap_id:, status:, user:) }
      let(:status) { :unnotified }

      before { notification_status }

      it "doesn't create new NotificationStatus, but updates existing one" do
        expect { perform_worker }.not_to change(NotificationStatus, :count)
        expect(notification_status.reload.status).to eq('notified')
      end

      context 'when existing NotificationStatus has status: :notified already' do
        let(:status) { :notified }

        it "doesn't create new NotificationStatus nor update existing one, doesn't send message to user" do
          expect { perform_worker }.not_to change(NotificationStatus, :count)
          expect(notification_status.reload.status).to eq('notified')
          expect(telegram_notifier_double).not_to have_received(:call)
        end
      end
    end
  end
end
