# frozen_string_literal: true

RSpec.shared_examples 'reply markup builder' do |*button_titles|
  subject(:call_service) { service.call(locale) }

  let(:service) { described_class.new }
  let(:locale) { :en }

  it { is_expected.to be_a(Telegram::Bot::Types::InlineKeyboardMarkup) }

  it 'sends proper buttons set' do
    expect(call_service.inline_keyboard.first.map(&:text)).to match_array(button_titles)
  end
end
