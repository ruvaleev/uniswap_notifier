# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe NotificationsSettings::Update do
  describe '#call' do
    subject(:call_service) { described_class.new.call(user, params) }

    let(:user) { create(:user) }
    let(:params) { { out_of_range: false } }

    context 'when user has notifications_setting' do
      let(:notifications_setting) { create(:notifications_setting, user:) }

      it "doesn't create new notifications_setting but updates existing one" do
        expect(notifications_setting.out_of_range).to be_truthy
        expect { call_service }.not_to change(NotificationsSetting, :count)
        expect(notifications_setting.out_of_range).to be_falsy
      end
    end

    context 'when user has no notifications_setting' do
      it 'creates new notifications_setting with proper params' do
        expect { call_service }.to change(NotificationsSetting, :count).by(1)
        expect(NotificationsSetting.last.out_of_range).to be_falsy
      end
    end

    context 'when validation failed error raised' do
      let(:params) { { out_of_range: nil } }
      let(:error_message) { 'Validation failed: Out of range is not included in the list' }

      it "doesn't create new notifications_setting and raises proper error" do
        expect { call_service }.to raise_error(ActiveRecord::RecordInvalid, error_message)
        expect(NotificationsSetting.count).to be_zero
      end
    end
  end
end
