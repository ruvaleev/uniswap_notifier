# frozen_string_literal: true

module Graphs
  class RevertFinance
    class ApiError < StandardError; end
    POOLS_FIELDS = %w[tick id].join(' ').freeze

    POSITIONS_FIELDS = %w[
      amountDepositedUSD
      depositedToken0
      depositedToken1
      feeGrowthInside0LastX128
      feeGrowthInside1LastX128
      id
      liquidity
      pool{id tick sqrtPrice feeGrowthGlobal0X128 feeGrowthGlobal1X128}
      tickLower
      tickUpper
      token0{symbol id decimals}
      token1{symbol id decimals}
      owner
    ].join(' ').freeze

    POSITIONS_TICKERS_FIELDS = %w[
      id
      pool{tick}
      tickLower
      tickUpper
    ].join(' ').freeze

    def pool(id, block_number)
      make_request(
        build_pool_body(id:, block_number:)
      )['data']['pools'].first
    end

    def positions(owner_address)
      make_request(
        build_positions_body(
          where: positions_where_clause(owner_address),
          fields: POSITIONS_FIELDS
        )
      )
    end

    def positions_tickers(owner_address, id_not_in: [])
      make_request(
        build_positions_body(
          where: positions_tickers_where_clause(owner_address, id_not_in),
          fields: POSITIONS_TICKERS_FIELDS
        )
      )
    end

    private

    def build_pool_body(id:, block_number:)
      { query: pools_query(id:, block_number:) }.to_json
    end

    def build_positions_body(where:, fields:)
      { query: positions_query(where:, fields:) }.to_json
    end

    def pools_query(id:, block_number:)
      <<~GQL
        {
          pools(
            block: {number: #{block_number}}
            where: {id: "#{id}"}
          ) {#{POOLS_FIELDS}}
        }
      GQL
    end

    def positions_tickers_where_clause(owner_address, id_not_in)
      positions_where_clause(owner_address) +
        (id_not_in.blank? ? '' : ", id_not_in: #{id_not_in}")
    end

    def positions_where_clause(owner_address)
      "owner: \"#{owner_address}\", liquidity_gt: 0"
    end

    def positions_query(where:, fields:)
      <<~GQL
        {
          positions(
            where: {#{where}}
          ) {#{fields}}
        }
      GQL
    end

    def make_request(body)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json', 'Accept' => 'json')
      request.body = body

      parse_response(
        http.request(request)
      )
    end

    def parse_response(response)
      raise ApiError, response.body unless response.is_a?(Net::HTTPSuccess)

      parsed_body = JSON.parse(response.body)
      raise ApiError, parsed_body['errors'].to_json if parsed_body['errors']

      parsed_body
    end

    def uri
      @uri ||= URI('https://api.thegraph.com/subgraphs/name/revert-finance/uniswap-v3-arbitrum')
    end
  end
end
