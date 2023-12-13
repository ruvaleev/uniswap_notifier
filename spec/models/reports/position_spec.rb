# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Reports::Position, type: :model do
  it { is_expected.to belong_to(:portfolio_report) }
  it { is_expected.to have_one(:position_report).dependent(:destroy) }

  describe '#divider_0' do
    subject(:divider_0) { position.divider_0 }

    let(:position) { build(:position, token_0: { 'decimals' => decimals }) }
    let(:decimals) { rand(18) }

    it { is_expected.to eq(10**decimals) }
  end

  describe '#divider_1' do
    subject(:divider_1) { position.divider_1 }

    let(:position) { build(:position, token_1: { 'decimals' => decimals }) }
    let(:decimals) { rand(18) }

    it { is_expected.to eq(10**decimals) }
  end

  describe '#report' do
    subject(:report) { position.report }

    let(:position) { create(:position) }

    context 'when position has no report yet' do
      it 'creates and returns new report for position' do
        expect { report }.to change(PositionReport, :count).by(1)
        expect(report).to have_attributes(position_id: position.id, status: 'initialized')
      end
    end

    context 'when position already has report' do
      let!(:existing_report) { create(:position_report, position:) }

      it "doesn't create new report and returns existing one" do
        expect { report }.not_to change(PositionReport, :count)
        expect(report).to eq(existing_report)
      end
    end
  end
end
