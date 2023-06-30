# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe RedisService do
  describe '.client' do
    subject(:client) { described_class.client }

    it { is_expected.to be_a(Redis) }
  end
end
