# frozen_string_literal: true

module Coingecko
  class Error < StandardError; end

  class UnknownToken < StandardError
    def initialize(symbol)
      super("Unknown token: #{symbol}")
    end
  end

  class Base
    COINGECKO_CURRENCIES = {
      ARB: 'arbitrum',
      AXS: 'axie-infinity',
      BLUR: 'blur',
      DAI: 'dai',
      ETH: 'ethereum',
      GHO: 'gho',
      GMX: 'gmx',
      LINK: 'chainlink',
      PSI: 'tridentdao',
      SHIB: 'shiba-inu',
      SPELL: 'spell-token',
      USDC: 'usd-coin',
      USDT: 'tether',
      WBTC: 'wrapped-bitcoin',
      WETH: 'weth',
      wstETH: 'wrapped-steth'
    }.with_indifferent_access.freeze

    private

    def make_request(uri)
      response = Net::HTTP.get_response(uri)
      parsed_body = JSON.parse(response.body)
      response.is_a?(Net::HTTPSuccess) ? parsed_body : raise_parsed_error(parsed_body)
    end

    def raise_parsed_error(parsed_body)
      raise Error, parsed_body['error']
    end

    def raise_unknown_token_error(symbol)
      raise UnknownToken, symbol
    end

    def to_coin_id(symbol)
      COINGECKO_CURRENCIES[symbol] || raise_unknown_token_error(symbol)
    end
  end
end
