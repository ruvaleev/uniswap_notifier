# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../concerns/workers_shared_examples'

RSpec.describe Positions::FillWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async(position_id) }

    let(:position_id) { position.id }
    let(:position) { create(:position) }
    let(:fill_service_double) { instance_double(Positions::Fill, call: true) }

    before { allow(Positions::Fill).to receive(:new).and_return(fill_service_double) }

    it_behaves_like 'sidekiq worker'

    it 'calls Positions::Fill with proper params', testing: :inline do
      perform_worker
      expect(fill_service_double).to have_received(:call).with(position, { status: :active }).once
    end
  end
end
