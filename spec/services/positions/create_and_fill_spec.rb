# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::CreateAndFill do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user, uniswap_id, rebalance_threshold_percents) }

    let(:user) { create(:user) }
    let(:uniswap_id) { rand(1000..5_000) }
    let(:rebalance_threshold_percents) { rand(50) }

    it 'creates and returns new position with proper params' do
      expect { call_service }.to change(user.positions.where(uniswap_id:, rebalance_threshold_percents:), :count).by(1)
      expect(call_service).to eq(user.positions.last)
    end

    it 'schedules created position to Positions::FillWorker' do
      expect { call_service }.to change(Positions::FillWorker.jobs, :size).by(1)
      expect(Positions::FillWorker.jobs.last['args']).to eq([call_service.id])
    end

    context 'when user already has position with provided :uniswap_id' do
      before { create(:position, user:, uniswap_id:) }

      it "raises proper error and doesn't create nor schedule new position" do
        Positions::FillWorker.jobs.clear
        expect { call_service }.to raise_error(ActiveRecord::RecordInvalid)
        expect(user.positions.count).to eq(1)
        expect(Positions::FillWorker.jobs.size).to eq(0)
      end
    end
  end
end
