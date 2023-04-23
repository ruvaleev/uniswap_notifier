# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['SINATRA_ENV'] = 'test'

require 'webmock/rspec'
require './config/environment'

require_all 'spec/support'
