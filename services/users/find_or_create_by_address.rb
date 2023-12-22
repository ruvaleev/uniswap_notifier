# frozen_string_literal: true

module Users
  class FindOrCreateByAddress
    def call(address)
      wallet = find_or_cerate_wallet(address)
      wallet.user
    end

    private

    def find_or_cerate_wallet(address)
      wallet = Wallet.find_by(address:)
      return wallet if wallet

      user = User.new
      Wallet.create!(user:, address:)
    end
  end
end
