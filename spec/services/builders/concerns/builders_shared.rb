# frozen_string_literal: true

RSpec.shared_context 'with mocked position_report build_message service' do
  let(:build_message_service_double) { instance_double(Builders::PositionReport::Message, call: 'message') }

  before { allow(Builders::PositionReport::Message).to receive(:new).and_return(build_message_service_double) }
end

RSpec.shared_context 'with mocked send_message service' do
  let(:response) { JSON.parse(File.read('spec/fixtures/telegram/bot_api/send_message/success.json')) }
  let(:send_message_service_double) { instance_double(Telegram::Reports::SendOrUpdateMessage, call: response) }

  before { allow(Telegram::Reports::SendOrUpdateMessage).to receive(:new).and_return(send_message_service_double) }
end

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
  include_context 'with mocked send_message service'

  it 'sends report' do
    call_service
    expect(send_message_service_double).to have_received(:call).once
  end
end

RSpec.shared_examples 'updates status to' do |new_status|
  it "updates portfolio status to '#{new_status}'" do
    expect { call_service }.to change(report, :status).to(new_status)
  end
end
