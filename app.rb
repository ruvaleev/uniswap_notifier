# frozen_string_literal: true

require './config/environment'

class App < Sinatra::Base
  def call(_env)
    200
  end
end
