# frozen_string_literal: true

module CoinGecko
  class Client
    class ApiError < StandardError; end

    include HTTParty

    BASE_URI = 'https://api.coingecko.com/api/v3'

    def usd_price(ids)
      query_params = { ids: ids.join(','), vs_currencies: 'usd' }
      get_request('/simple/price', query_params).transform_values! { |h| h['usd'] }
    end

    private

    def get_request(path, query_params = {})
      response = self.class.get(BASE_URI + path, query: query_params)
      response.success? ? response.parsed_response : raise(ApiError)
    end
  end
end
