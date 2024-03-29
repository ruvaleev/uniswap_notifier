# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::HandleCallback do
  describe '#call' do
    subject(:call_service) { described_class.new.call(callback_body) }

    let(:callback_body) { JSON.parse(File.read("spec/fixtures/telegram/#{callback_name}.json")) }

    shared_examples 'schedules SendInitialMenuWorker for existing user' do
      it 'schedules SendInitialMenuWorker for existing user' do
        expect { call_service }.to change(SendInitialMenuWorker.jobs, :size).by(1)
        expect(SendInitialMenuWorker.jobs.last['args']).to match_array([user.id])
      end
    end

    context 'when in body start callback' do
      let(:callback_name) { :start_callback }
      let(:token) { 'token_is_here' }
      let(:user) { create(:user) }

      context 'when there is :user_id for provided token in cache' do
        before { RedisService.client.set(token, user.id) }

        it 'assigns chat_id to the user' do
          expect { call_service }.to change { user.reload.telegram_chat_id }.from(nil).to(999_887_755)
        end

        it_behaves_like 'schedules SendInitialMenuWorker for existing user'
      end

      context 'when there is no :user_id for provided token in cache' do
        it "doesn't change user's :telegram_chat_id" do
          expect { call_service }.not_to change { user.reload.telegram_chat_id }
        end

        it "doesn't schedules SendInitialMenuWorker" do
          expect { call_service }.not_to change(SendInitialMenuWorker.jobs, :size)
        end
      end

      context 'when there is already User with provided chat_id' do
        let!(:user) { create(:user, telegram_chat_id: 999_887_755) } # rubocop:disable RSpec/LetSetup

        it_behaves_like 'schedules SendInitialMenuWorker for existing user'
      end
    end

    context 'when there is other text in body' do
      let(:callback_name) { :message_callback }
      let(:telegram_chat_id) { 999_887_755 } # from the fixture
      let!(:user) { create(:user, telegram_chat_id:) }

      it { is_expected.to be_nil }

      context 'when there is /portoflio_report in body' do
        before { callback_body['message']['text'] = '/portfolio_report' }

        it 'finds user with same chat id and asynchronously calls BuildPortfolioReportWorker for him' do
          expect { call_service }.to change(BuildPortfolioReportWorker.jobs, :size).by(1)
          expect(BuildPortfolioReportWorker.jobs.last['args']).to match_array([user.id])
        end
      end

      context 'when there is /contact_us in body' do
        before { callback_body['message']['text'] = '/contact_us' }

        it 'sends link to current support manager' do
          expect { call_service }.to change(SendSupportContactWorker.jobs, :size).by(1)
          expect(SendSupportContactWorker.jobs.last['args']).to match_array([telegram_chat_id])
        end
      end

      context 'when there is /menu in body' do
        before { callback_body['message']['text'] = '/menu' }

        it 'sends menu' do
          expect { call_service }.to change(SendMenuWorker.jobs, :size).by(1)
          expect(SendMenuWorker.jobs.last['args']).to match_array([telegram_chat_id])
        end
      end
    end

    context 'when callback_body is empty' do
      let(:callback_body) { {} }

      it { is_expected.to be_nil }
    end

    context 'when there is callback_query in the body' do
      let(:callback_name) { 'callbacks/portfolio_report' }
      let(:telegram_chat_id) { 999_887_755 } # from the fixture
      let!(:user) { create(:user, telegram_chat_id:) }

      context "with 'portfolio_report' in data" do
        it 'finds user with same chat id and asynchronously calls BuildPortfolioReportWorker for him' do
          expect { call_service }.to change(BuildPortfolioReportWorker.jobs, :size).by(1)
          expect(BuildPortfolioReportWorker.jobs.last['args']).to match_array([user.id])
        end
      end

      context "with 'menu' in data" do
        before { callback_body['callback_query']['data'] = 'menu' }

        it 'sends menu' do
          expect { call_service }.to change(SendMenuWorker.jobs, :size).by(1)
          expect(SendMenuWorker.jobs.last['args']).to match_array([telegram_chat_id])
        end
      end
    end
  end
end
