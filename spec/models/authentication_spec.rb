# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Authentication, type: :model do
  subject(:authentication) { build(:authentication) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:ip_address) }
  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_presence_of(:user_id) }
end
