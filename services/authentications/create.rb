# frozen_string_literal: true

module Authentications
  class Create
    def call(user, ip_address)
      user.authentications.create!(
        token: SecureRandom.hex,
        ip_address:,
        last_usage_at: Time.now
      )
    end
  end
end
