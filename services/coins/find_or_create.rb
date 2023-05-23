# frozen_string_literal: true

module Coins
  class FindOrCreate
    def call(address)
      find_coin(address) || create_coin(address)
    end

    private

    def find_coin(address)
      Coin.find_by(address:)
    end

    def create_coin(address)
      token_data = BlockchainDataFetcher::Client.token_data(address)
      Coin.create!(address:, name: token_data.name, symbol: token_data.symbol, decimals: token_data.decimals)
    end
  end
end
