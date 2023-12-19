# frozen_string_literal: true

module Builders
  class PositionReport
    def call(position_report)
      position_report.send_message

      case position_report.status.to_sym
      when :fees_info_fetching
        process_fees_info_fetching_report(position_report)
      when :history_analyzing
        process_history_analyzing_report(position_report)
      end
    end

    private

    def process_fees_info_fetching_report(position_report)
      position = position_report.position
      fees = calculate_fees(position)
      amounts = calculate_amounts(position)

      position.token_0.merge!(amount: amounts[:amount_0], fees: fees[:fees_0])
      position.token_1.merge!(amount: amounts[:amount_1], fees: fees[:fees_1])
      position.save!
      position_report.update!(status: :history_analyzing)
      call(position_report)
    end

    def calculate_fees(position)
      contract = Blockchain::Arbitrum::PoolContract.new(position.pool['id'])
      tick_lower = contract.ticks(position.tick_lower)
      tick_upper = contract.ticks(position.tick_upper)
      Positions::CalculateFees.new(position, tick_lower, tick_upper).call
    end

    def calculate_amounts(position)
      Positions::CalculateAmounts.new(position).call
    end

    def process_history_analyzing_report(position_report)
      position = position_report.position
      parsed_events = Builders::Position::ParsedEvents.new.call(position)
      initial_block_params = initial_block_params(position.pool['id'], parsed_events[:liquidity_increases].first)
      position.update!(**parsed_events, **initial_block_params)
      position_report.update!(status: :completed)
      call(position_report)
    end

    def initial_block_params(pool_id, initial_increase)
      pool = Graphs::RevertFinance.new.pool(pool_id, initial_increase[:block_number])

      {
        initial_tick: pool['tick'],
        initial_timestamp: Time.at(initial_increase[:timestamp])
      }
    end
  end
end
