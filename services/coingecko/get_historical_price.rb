# frozen_string_literal: true

module Coingecko
  class GetHistoricalPrice < Base
    def call(symbol, date)
      coin_id = to_coin_id(symbol)
      price = fetch_historical_price(symbol, coin_id, date.to_s)

      BigDecimal(price)
    end

    private

    def fetch_historical_price(symbol, coin_id, string_date)
      RedisService.fetch(cache_key(symbol, string_date)) do
        parsed_body = request_history_price(coin_id, string_date)
        serialize_response(parsed_body)
      end
    end

    def cache_key(symbol, string_date)
      "usd_price_#{symbol}_#{string_date}"
    end

    def request_history_price(coin_id, date)
      make_request(
        URI("https://api.coingecko.com/api/v3/coins/#{coin_id}/history?date=#{date}")
      )
    end

    def serialize_response(parsed_body)
      parsed_body['market_data']['current_price']['usd'].to_s
    end
  end
end
