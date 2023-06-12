# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to have_many(:positions).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_uniqueness_of(:address) }
  it { is_expected.to validate_presence_of(:login) }
  it { is_expected.to validate_uniqueness_of(:login) }
  it { is_expected.to validate_presence_of(:password_hash) }

  describe '#password=' do
    subject(:assign_password) { user.password = password }

    let(:password) { SecureRandom.hex(4) }

    it 'writes hashed password to the password_hash field' do
      expect { assign_password }.to change(user, :password_hash)
      expect(user.password_hash).not_to eq(password)
    end

    context 'when password is not string' do
      let(:password) { rand(1_000_000..2_000_000) }

      it 'writes its string version to @password instance variable' do
        expect { assign_password }.to change {
          user.instance_variable_get('@password')
        }.from(nil).to(password.to_s)
      end
    end
  end

  describe 'password_length validation' do
    let(:too_short_password) { rand(0...100_000) }
    let(:too_long_password) { 10**22 }
    let(:valid_password) { SecureRandom.hex(4) }

    it 'validates password length' do
      expect(user).to be_valid

      user.password = too_short_password
      expect(user).not_to be_valid

      user.password = too_long_password
      expect(user).not_to be_valid

      expect(user.errors.messages).to eq({ password: ['is invalid'] })

      user.password = valid_password
      expect(user).to be_valid
      expect(user.errors.messages).to eq({})
    end
  end
end
