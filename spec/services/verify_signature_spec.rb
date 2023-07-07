# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe VerifySignature do
  describe '#call' do
    subject(:call_service) { described_class.new.call(address:, message:, signature:, chain_id:) }

    let(:address) { '0x1542daDDa32ba086434D589a8f005176D6E650B4' }
    let(:message) { '1' }
    let(:chain_id) { 42_161 }

    context 'when signature valid' do
      let(:signature) do
        '0xd5fb766281af5da544c79e8f1ed81a705e4bea0429a313aeab0648e0f1aeee601cf1e63534da5bf94ecae61bc950d0dd0e03eca85e23c2cb9b4903b4b3ca81da1c' # rubocop:disable Layout/LineLength
      end

      it { is_expected.to be_truthy }
    end

    context 'when signature invalid' do
      let(:signature) do
        '1xd5fb766281af5da544c79e8f1ed81a705e4bea0429a313aeab0648e0f1aeee601cf1e63534da5bf94ecae61bc950d0dd0e03eca85e23c2cb9b4903b4b3ca81da1c' # rubocop:disable Layout/LineLength
      end

      it { is_expected.to be_falsey }
    end
  end
end
