# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::ShouldRebalanceCheck do
  describe '#call' do
    subject(:call_service) { described_class.new.call(current_tick:, lower_tick:, upper_tick:, threshold:) }

    let(:current_tick) { 200_000 }
    let(:lower_tick) { 180_000 }
    let(:upper_tick) { 220_000 }
    let(:threshold) { 10 }

    context 'when :current_tick is in the safe range according to threshold' do
      it { is_expected.to be_falsey }
    end

    context 'when :current_tick is too low' do
      let(:current_tick) { 184_000 }

      it { is_expected.to be_truthy }
    end

    context 'when :current_tick is too high' do
      let(:current_tick) { 216_000 }

      it { is_expected.to be_truthy }
    end

    context 'when ticks are negative' do
      let(:current_tick) { -200_000 }
      let(:lower_tick) { -220_000 }
      let(:upper_tick) { -180_000 }

      it { is_expected.to be_falsey }
    end
  end
end
