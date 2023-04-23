# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe CoinGecko::CoinId do
  describe '#call' do
    subject(:call_service) { described_class.new.call(code) }

    let(:code) { 'eTh' }

    it 'returns proper coingecko_id ignoring register of provided code' do
      expect(call_service).to eq('ethereum')
    end

    context 'when coin not found' do
      let(:code) { SecureRandom.hex }

      it { is_expected.to be_nil }
    end
  end
end
