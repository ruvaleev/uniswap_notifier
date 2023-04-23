# frozen_string_literal: true

class Currency::ActualizePrices # rubocop:disable Style/ClassAndModuleChildren
  def call
    update_currencies(
      CoinGecko::Client.new.usd_price(coingecko_ids.values)
    )
  end

  private

  def update_currencies(actual_prices)
    values_list = coingecko_ids.map { |key, v| "(#{key}, #{actual_prices[v] || 'NULL'})" }.join(', ')

    sql = <<~SQL.squish
      UPDATE currencies
      SET usd_price = new_values.usd_price
      FROM (VALUES #{values_list}) AS new_values (id, usd_price)
      WHERE currencies.id = new_values.id;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def coingecko_ids
    @coingecko_ids ||=
      Currency.pluck(:id, :code).to_h.transform_values! { |code| coin_id_service.call(code) }
  end

  def coin_id_service
    @coin_id_service || CoinGecko::CoinId.new
  end
end
