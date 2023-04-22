# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Currency, type: :model do
  it { is_expected.to have_many(:from_positions).class_name(:Position).dependent(:destroy) }
  it { is_expected.to have_many(:to_positions).class_name(:Position).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:code) }
end
