# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= ENV.fetch('RACK_ENV', 'development')

require 'dotenv'
Dotenv.load(".env.#{ENV.fetch('RACK_ENV', nil)}", ".env.#{ENV.fetch('SINATRA_ENV', nil)}", '.env.local', '.env')

require 'bundler/setup'
require 'rollbar/middleware/sinatra'
require 'telegram/bot'
Bundler.require(:default, ENV.fetch('SINATRA_ENV', nil))

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']) if ENV['DATABASE_URL']

require_all 'config/initializers'
require_all 'models'
require_all 'services'
require_all 'workers'

require './app'
