# frozen_string_literal: true

module NotificationsSettings
  class Update
    UPDATABLE_ATTRS = %i[out_of_range].freeze

    def call(user, params)
      nofitications_setting = user.notifications_setting || user.build_notifications_setting
      nofitications_setting.update!(
        params.slice(*UPDATABLE_ATTRS)
      )
    end
  end
end
