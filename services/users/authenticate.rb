# frozen_string_literal: true

module Users
  class Authenticate
    MAX_AUTHENTICATIONS = 2

    def call(address, ip_address)
      user = find_or_create_user(address)
      authentication = Authentications::Create.new.call(user, ip_address)
      clear_extra_authentications(user)
      authentication.token
    end

    private

    def find_or_create_user(address)
      user = User.find_or_initialize_by(address:)
      user.save unless user.persisted?

      user
    end

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
