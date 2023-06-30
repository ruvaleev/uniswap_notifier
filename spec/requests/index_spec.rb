# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'GET /' do
  subject(:send_request) { get '/' }

  it 'returns successful response' do
    expect(send_request.status).to eq(200)
  end
end
