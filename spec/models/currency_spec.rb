# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Currency, type: :model do
  it { is_expected.to validate_presence_of(:code) }
end
