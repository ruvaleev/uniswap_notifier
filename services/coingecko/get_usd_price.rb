# frozen_string_literal: true

module Coingecko
  class Error < StandardError; end

  class UnknownToken < StandardError
    def initialize(symbol)
      super("Unknown token: #{symbol}")
    end
  end

  class GetUsdPrice
    COINGECKO_CURRENCIES = {
      ARB: 'arbitrum',
      USDC: 'usd-coin',
      USDT: 'tether',
      WBTC: 'wrapped-bitcoin',
      WETH: 'ethereum'
    }.with_indifferent_access.freeze

    def call(*symbols)
      coin_ids = coin_ids_param(symbols)
      parsed_body = make_request(coin_ids)
      serialize_response(parsed_body)
    end

    private

    def coin_ids_param(symbols)
      symbols.map do |symbol|
        COINGECKO_CURRENCIES[symbol] || raise_unknown_token_error(symbol)
      end.join(',')
    end

    def make_request(coin_ids)
      uri = URI("https://api.coingecko.com/api/v3/simple/price?ids=#{coin_ids}&vs_currencies=usd")
      response = Net::HTTP.get_response(uri)
      parsed_body = JSON.parse(response.body)
      response.is_a?(Net::HTTPSuccess) ? parsed_body : raise_parsed_error(parsed_body)
    end

    def serialize_response(parsed_body)
      inverted_currencies = COINGECKO_CURRENCIES.invert
      parsed_body.to_h { |key, hash| [inverted_currencies[key], hash['usd']] }.with_indifferent_access
    end

    def uri_with_ids(ids)
      URI("https://api.coingecko.com/api/v3/simple/price?ids=#{ids}&vs_currencies=usd")
    end

    def raise_unknown_token_error(symbol)
      raise UnknownToken, symbol
    end

    def raise_parsed_error(parsed_body)
      raise Error, parsed_body['error']
    end
  end
end
