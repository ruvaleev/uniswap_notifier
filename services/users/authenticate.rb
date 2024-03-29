# frozen_string_literal: true

module Users
  class Authenticate
    MAX_AUTHENTICATIONS = 2

    def call(address, ip_address)
      user = Users::FindOrCreateByAddress.new.call(address)
      authentication = Authentications::Create.new.call(user, ip_address)
      clear_extra_authentications(user)
      authentication.token
    end

    private

    def clear_extra_authentications(user)
      user.authentications
          .where("id NOT IN (
                  SELECT id FROM authentications
                  WHERE user_id = :user_id
                  ORDER BY last_usage_at DESC
                  LIMIT :limit
                )", user_id: user.id, limit: MAX_AUTHENTICATIONS)
          .delete_all
    end
  end
end
