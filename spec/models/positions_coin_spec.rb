# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe PositionsCoin, type: :model do
  it { is_expected.to belong_to(:coin) }
  it { is_expected.to belong_to(:position) }

  it { is_expected.to validate_presence_of(:coin_id) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:position_id) }

  context 'with persisted relations' do
    subject(:positions_coin) { create(:positions_coin) }

    it { is_expected.to validate_uniqueness_of(:number).case_insensitive.scoped_to(:position_id) }
  end
end
