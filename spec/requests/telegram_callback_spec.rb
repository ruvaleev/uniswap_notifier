# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'POST /telegram_callback' do
  subject(:send_request) { post '/telegram_callback', params }

  context 'when /start callback has been send' do
    let(:token) { 'token_is_here' }
    let(:params) { JSON.parse(File.read('spec/fixtures/telegram/start_callback.json')) }
    let(:handle_callback_double) { instance_double(Telegram::HandleCallback, call: true) }

    before { allow(Telegram::HandleCallback).to receive(:new).and_return(handle_callback_double) }

    it 'passes provided params to Telegram::HandleCallback service' do
      expect(send_request.status).to eq(200)
      expect(handle_callback_double).to have_received(:call).once
    end
  end
end
