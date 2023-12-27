# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/reply_markups_shared'

RSpec.describe Builders::Telegram::ReplyMarkups::Menu do
  describe '#call' do
    it_behaves_like 'reply markup builder', I18n.t('menu.portfolio_report'), I18n.t('menu.contact_us')
  end
end
