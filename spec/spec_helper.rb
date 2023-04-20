# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require './config/environment'
require './coin_gecko_client'

require 'webmock/rspec'

require_all 'spec/support'
