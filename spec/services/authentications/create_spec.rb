# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Authentications::Create do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user, ip_address) }

    let(:user) { create(:user) }
    let(:ip_address) { "123.45.67.#{rand(100)}" }

    it 'creates new authentication for provided user and returns its code' do
      expect { call_service }.to change(user.authentications, :count).by(1)
      expect(call_service).to eq(user.authentications.last)
      expect(user.authentications.last).to have_attributes(ip_address:)
    end
  end
end
