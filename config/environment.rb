# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, ENV.fetch('SINATRA_ENV', nil))

require_all 'models'
