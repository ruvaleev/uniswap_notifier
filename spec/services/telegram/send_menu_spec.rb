# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Telegram::SendMenu do
  describe '#call' do
    subject(:call_service) { described_class.new.call(chat_id) }

    let(:chat_id) { rand(100) }
    let!(:user) { create(:user, telegram_chat_id: chat_id, locale: :en) } # rubocop:disable RSpec/LetSetup
    let(:text) { I18n.t('menu.choose_action') }
    let(:send_message_double) { instance_double(Telegram::SendMessage, call: 2829) }
    let(:reply_markup) { Builders::Telegram::ReplyMarkups::Menu.new.call(:en) }

    before do
      allow(Telegram::SendMessage).to receive(:new).and_return(send_message_double)
    end

    it 'sends message with current support manager' do
      call_service
      expect(send_message_double).to have_received(:call).with(chat_id:, text:, reply_markup:).once
    end
  end
end
