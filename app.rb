# frozen_string_literal: true

require './config/environment'

error Authentications::NotFound do 401 end # rubocop:disable Style/BlockDelimiters

get '/authenticate' do
  return 401 unless valid_signature?

  headers 'Authentication' => Users::Authenticate.new.call(params[:address], request.ip)
  200
end

get '/' do
  slim :index
end

get '/telegram_link' do
  { link: Telegram::CreateLink.new.call(current_user.id) }.to_json
end

post '/telegram_callback' do
  Telegram::HandleCallback.new.call(params)
  200
end

def valid_signature?
  VerifySignature.new.call(
    address: params[:address],
    message: params[:message],
    signature: params[:signature],
    chain_id: params[:chain_id].to_i
  )
end

def current_user
  @current_user ||= Authentications::Check.new.call(request.env['Authorization'], request.ip)
end
