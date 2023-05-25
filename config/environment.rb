# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= 'development'

require 'telegram/bot'
require 'bundler/setup'
Bundler.require(:default, ENV.fetch('SINATRA_ENV', nil))

config = YAML.load_file('config/secrets.yml')[ENV.fetch('SINATRA_ENV', nil)] if File.file?('config/secrets.yml')
config&.each { |name, value| ENV[name] ||= value }
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']) if ENV['DATABASE_URL']

require_all 'config/initializers'
require './app'
require_all 'lib'
require_all 'models'
require_all 'queries'
require_all 'services'
require_all 'workers'
