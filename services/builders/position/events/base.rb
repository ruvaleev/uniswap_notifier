# frozen_string_literal: true

module Builders
  module Position
    module Events
      class Base
        def call(position)
          position.events[self.class::EVENT_NAME].map { |log| parse_log(position, log) }
        end

        private

        def parse_log(position, log)
          timestamp = Blockchain::Arbitrum::Client.block_timestamp(log['blockNumber'])
          date = Time.at(timestamp).to_date

          result_message(log, position.token_0, position.token_1, timestamp, date)
        end

        def result_message(log, token_0, token_1, timestamp, date)
          {
            block_number: log['blockNumber'],
            timestamp:,
            amount_0: readable_amount(log['amount0'], token_0['decimals']),
            amount_1: readable_amount(log['amount1'], token_1['decimals']),
            usd_price_0: price_service.call(token_0['symbol'], date),
            usd_price_1: price_service.call(token_1['symbol'], date)
          }
        end

        def readable_amount(amount, decimals)
          BigDecimal(amount.to_s) / (10**decimals.to_i)
        end

        def price_service
          @price_service ||= Coingecko::GetHistoricalPrice.new
        end
      end
    end
  end
end
