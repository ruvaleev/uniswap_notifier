# frozen_string_literal: true

require './config/environment'
require 'sinatra'

error Authentications::NotFound do 401 end # rubocop:disable Style/BlockDelimiters

before do
  response.headers['Access-Control-Allow-Origin'] = allowed_origin
  response.headers['Access-Control-Allow-Credentials'] = 'true'
end

options '*' do
  response.headers['Access-Control-Allow-Headers'] = 'content-type'
  response.headers['Access-Control-Allow-Methods'] = 'GET'
  200
end

post '/authenticate' do
  return 401 unless valid_signature?

  set_auth_token(params[:address], request.ip)
  200
end

get '/check_auth' do
  200 if current_user
end

get '/telegram_link' do
  { link: Telegram::CreateLink.new.call(current_user.id) }.to_json
end

post '/telegram_callback' do
  Telegram::HandleCallback.new.call(params)
  200
end

def allowed_origin
  ENV['ORIGINS_URLS'].split(', ').find { |origin| origin == request.env['HTTP_ORIGIN'] } || ''
end

def current_user
  @current_user ||= Authentications::Check.new.call(request.cookies['Authentication'], request.ip)
end

def valid_signature?
  VerifySignature.new.call(
    address: params[:address],
    message: params[:message],
    signature: params[:signature],
    chain_id: params[:chain_id].to_i(16)
  )
end

def set_auth_token(address, ip_address)
  response.set_cookie(
    'Authentication',
    {
      value: Users::Authenticate.new.call(address, ip_address),
      expires: 1.hour.since,
      secure: true,
      http_only: true
    }
  )
end
