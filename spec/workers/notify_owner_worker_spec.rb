# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe NotifyOwnerWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(address, uniswap_id, message_type) }

    let(:user) { create(:user, telegram_chat_id: chat_id) }
    let(:address) { user.address }
    let(:chat_id) { rand(100).to_s }
    let(:uniswap_id) { rand(100) }
    let(:message_type) { 'out_of_range' }
    let(:message) { "Your position is OUT OF RANGE (needs rebalancing): https://app.uniswap.org/#/pools/#{uniswap_id}" }
    let(:telegram_notifier_double) { instance_double(TelegramNotifier, call: true) }

    before do
      allow(TelegramNotifier).to receive(:new)
        .with(chat_id, message).and_return(telegram_notifier_double)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls TelegramNotifier with proper params', testing: :inline do
      perform_worker
      expect(telegram_notifier_double).to have_received(:call).once
    end

    context 'when there is no NotificationStatus for position yet', testing: :inline do
      it 'creates NotificationStatus and moves it to :out_of_range status' do
        expect { perform_worker }.to change(NotificationStatus, :count).by(1)
        expect(NotificationStatus.last).to have_attributes(
          user_id: user.id, uniswap_id:, status: 'out_of_range'
        )
      end
    end

    context 'when there is existing NotificationStatus for position already', testing: :inline do
      let(:notification_status) { create(:notification_status, uniswap_id:, status:, user:, last_sent_at:) }
      let(:last_sent_at) { Time.now - (described_class::NOTIFICATION_TIMEOUT_SECONDS + 1) }

      before { notification_status }

      context 'when existing NotificationStatus has status: :in_range' do
        let(:status) { :in_range }

        it "doesn't create new NotificationStatus, but updates existing one" do
          expect { perform_worker }.not_to change(NotificationStatus, :count)
          expect(notification_status.reload.status).to eq('out_of_range')
        end

        context 'when :last_sent_at of notification status is less than NOTIFICATION_TIMEOUT_SECONDS ago' do
          let(:last_sent_at) { Time.now - (described_class::NOTIFICATION_TIMEOUT_SECONDS - 1) }

          it "doesn't create new NotificationStatus, doesn't update existing one" do
            expect { perform_worker }.not_to change(NotificationStatus, :count)
            expect(notification_status.reload.status).to eq('in_range')
          end
        end
      end

      context 'when existing NotificationStatus has status: :out_of_range already' do
        let(:status) { :out_of_range }

        it "doesn't create new NotificationStatus nor update existing one, doesn't send message to user" do
          expect { perform_worker }.not_to change(NotificationStatus, :count)
          expect(notification_status.reload.status).to eq('out_of_range')
          expect(telegram_notifier_double).not_to have_received(:call)
        end
      end
    end
  end
end
