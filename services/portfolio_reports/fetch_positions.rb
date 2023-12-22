# frozen_string_literal: true

module PortfolioReports
  class FetchPositions
    include GraphQueryable

    attr_reader :addresses, :portfolio_report_id

    COLUMNS_MATCHES = {
      fee_growth_inside_last_X128_0: 'feeGrowthInside0LastX128',
      fee_growth_inside_last_X128_1: 'feeGrowthInside1LastX128',
      liquidity: 'liquidity',
      owner: 'owner',
      pool: 'pool',
      tick_lower: 'tickLower',
      tick_upper: 'tickUpper',
      token_0: 'token0',
      token_1: 'token1',
      uniswap_id: 'id'
    }.freeze

    def initialize(portfolio_report)
      @addresses = Wallet.where(user_id: portfolio_report.user_id).pluck(:address)
      @portfolio_report_id = portfolio_report.id
    end

    def call
      return if addresses.empty?

      collection = api_service.positions(*addresses)['data']['positions']
      save_positions(collection)
    end

    private

    def save_positions(positions)
      ActiveRecord::Base.connection.execute(sql(positions))
    end

    def sql(positions)
      columns = [%i[portfolio_report_id] + COLUMNS_MATCHES.keys].join(', ')
      values = build_values(positions, *COLUMNS_MATCHES.values)

      <<-SQL.squish
        WITH inserted_positions AS (
          INSERT INTO positions (#{columns})
          VALUES #{values}
          ON CONFLICT (uniswap_id, portfolio_report_id)
          DO UPDATE SET
            liquidity = EXCLUDED.liquidity
          RETURNING id
        )
        INSERT INTO position_reports (position_id, created_at, updated_at)
        SELECT id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM inserted_positions
        WHERE NOT EXISTS (
          SELECT 1 FROM position_reports WHERE position_id = inserted_positions.id
        );
      SQL
    end

    def build_values(positions, *fields_names)
      positions.map do |pos|
        "(
          #{portfolio_report_id},
          #{fields_names.map { |field| "'#{serialized(pos[field])}'" }.join(', ')}
        )".squish
      end.join(', ')
    end

    def serialized(value)
      value.is_a?(Hash) ? value.to_json : value
    end
  end
end
