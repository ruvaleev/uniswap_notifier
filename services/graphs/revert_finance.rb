# frozen_string_literal: true

module Graphs
  class RevertFinance
    POSITIONS_FIELDS = %w[
      amountCollectedUSD
      amountDepositedUSD
      amountWithdrawnUSD
      collectedFeesToken0
      collectedFeesToken1
      collectedToken0
      collectedToken1
      depositedToken0
      depositedToken1
      feeGrowthInside0LastX128
      feeGrowthInside1LastX128
      id
      liquidity
      tickLower
      tickUpper
      withdrawnToken0
      withdrawnToken1
      owner
    ].join(' ').freeze

    POSITIONS_TICKERS_FIELDS = %w[
      id
      pool{tick}
      tickLower
      tickUpper
    ].join(' ').freeze

    def positions(owner_address)
      response = make_request(
        build_positions_body(owner_address, fields: POSITIONS_FIELDS)
      )
      JSON.parse(response.body)
    end

    def positions_tickers(owner_address)
      response = make_request(
        build_positions_body(owner_address, fields: POSITIONS_TICKERS_FIELDS)
      )
      JSON.parse(response.body)
    end

    private

    def build_positions_body(owner_address, fields:)
      { query: positions_query(owner_address, fields:) }.to_json
    end

    def positions_query(owner_address, fields:)
      <<~GQL
        {
          positions(
            where: {owner: "#{owner_address}", liquidity_gt: "0"}
          ) {#{fields}}
        }
      GQL
    end

    def make_request(body)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json', 'Accept' => 'json')
      request.body = body
      http.request(request)
    end

    def uri
      @uri ||= URI('https://api.thegraph.com/subgraphs/name/revert-finance/uniswap-v3-arbitrum')
    end
  end
end
