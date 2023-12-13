# frozen_string_literal: true

module Coingecko
  class GetUsdPrice < Base
    def call(*symbols)
      coin_ids = coin_ids_param(symbols)
      parsed_body = request_price(coin_ids)
      serialize_response(parsed_body)
    end

    private

    def coin_ids_param(symbols)
      symbols.map { |symbol| to_coin_id(symbol) }.join(',')
    end

    def request_price(coin_ids)
      make_request(
        URI("https://api.coingecko.com/api/v3/simple/price?ids=#{coin_ids}&vs_currencies=usd")
      )
    end

    def serialize_response(parsed_body)
      inverted_currencies = COINGECKO_CURRENCIES.invert
      parsed_body.to_h { |key, hash| [inverted_currencies[key], hash['usd']] }.with_indifferent_access
    end
  end
end
