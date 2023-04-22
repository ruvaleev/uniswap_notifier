# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= 'development'

require 'telegram/bot'
require 'bundler/setup'
Bundler.require(:default, ENV.fetch('SINATRA_ENV', nil))

config = YAML.load_file('secrets.yml')[ENV.fetch('SINATRA_ENV', nil)] if File.file?('secrets.yml')
config&.each { |name, value| ENV[name] ||= value }
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']) if ENV['DATABASE_URL']

require_all 'models'
require_all 'services'
