# frozen_string_literal: true

require './config/environment'

get '/authenticate' do
  return 401 unless valid_signature?

  headers 'Authentication' => Users::Authenticate.new.call(params[:address], request.ip)

  200
end

get '/' do
  slim :index
end

def valid_signature?
  VerifySignature.new.call(
    address: params[:address],
    message: params[:message],
    signature: params[:signature],
    chain_id: params[:chain_id].to_i
  )
end
