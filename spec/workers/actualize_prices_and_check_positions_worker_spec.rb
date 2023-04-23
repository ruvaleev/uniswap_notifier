# frozen_string_literal: true

require './spec/spec_helper'
require_relative 'concerns/workers_shared_examples'

RSpec.describe ActualizePricesAndCheckPositionsWorker do
  describe '#perform' do
    subject(:perform_worker) { described_class.perform_async }

    let(:actualize_prices_double) { instance_double(Currency::ActualizePrices, call: true) }

    before do
      allow(Currency::ActualizePrices).to receive(:new).and_return(actualize_prices_double)
      allow(CheckPositionsWorker).to receive(:perform_async)
    end

    it_behaves_like 'sidekiq worker'

    it 'calls Currency::ActualizePrices with schedules CheckPositionsWorker', testing: :inline do
      perform_worker
      expect(actualize_prices_double).to have_received(:call).once
      expect(CheckPositionsWorker).to have_received(:perform_async).once
    end
  end
end
