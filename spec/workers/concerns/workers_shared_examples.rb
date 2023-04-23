# frozen_string_literal: true

RSpec.shared_examples 'sidekiq worker' do
  it 'pushes job on the queue' do
    expect { perform_worker }.to change(described_class.jobs, :size).by(1)
  end
end
