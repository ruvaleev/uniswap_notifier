# frozen_string_literal: true

RSpec.shared_context 'with recursively called service' do
  before do
    call_count = 0
    allow(service).to receive(:call).and_wrap_original do |original_method, *args|
      call_count += 1
      call_count == 1 ? original_method.call(*args) : true
    end
  end
end

RSpec.shared_examples 'calls itself recursively' do
  it 'uses :call method again after initial call' do
    call_service
    expect(service).to have_received(:call).twice
  end
end

RSpec.shared_examples "doesn't call itself recursively" do
  it "doesn't use :call method after initial call" do
    call_service
    expect(service).to have_received(:call).once
  end
end

RSpec.shared_examples 'sends report' do
  before { allow(report).to receive(:send_message) }

  it 'sends report' do
    call_service
    expect(report).to have_received(:send_message).once
  end
end

RSpec.shared_examples 'updates status to' do |new_status|
  it "updates portfolio status to '#{new_status}'" do
    expect { call_service }.to change(report, :status).to(new_status)
  end
end
