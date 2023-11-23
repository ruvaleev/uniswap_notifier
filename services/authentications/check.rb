# frozen_string_literal: true

module Authentications
  class NotFound < StandardError; end

  class Check
    def call(token, ip_address)
      find_authentication(token, ip_address).user
    end

    private

    def find_authentication(token, ip_address)
      authentication = Authentication.find_by(token:, ip_address:)
      raise NotFound unless authentication

      authentication
    end
  end
end
