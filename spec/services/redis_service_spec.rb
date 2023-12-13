# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe RedisService do
  describe '.client' do
    subject(:client) { described_class.client }

    it { is_expected.to be_a(Redis) }
  end

  describe '.fetch' do
    subject(:fetch) { described_class.fetch(key) { service.hex } }

    let(:key) { :some_cache_key }
    let(:service) { class_double(SecureRandom) }
    let(:hex) { SecureRandom.uuid }

    before { allow(service).to receive(:hex).and_return(hex) }

    context 'when value is already in cache' do
      let(:cached_value) { 'cached_value' }

      before { described_class.client.set(key, cached_value) }

      it "returns cached value and doesn't call provided block" do
        expect(fetch).to eq(cached_value)
        expect(service).not_to have_received(:hex)
      end
    end

    context 'when value is not in cache yet' do
      it "returns cached value and doesn't call provided block" do
        expect(fetch).to eq(hex)
        expect(service).to have_received(:hex).once
        expect(described_class.client.get(key)).to eq(hex)
      end
    end
  end
end
