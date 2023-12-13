# frozen_string_literal: true

module Builders
  class PositionReport
    def call(position_report)
      position_report.send_message

      case position_report.status.to_sym
      when :initialized
        process_initialized_report(position_report)
      when :fees_info_fetched
        process_fees_info_fetched_report(position_report)
      end
    end

    private

    def process_initialized_report(position_report)
      position = position_report.position
      fees = calculate_fees(position)
      amounts = calculate_amounts(position)

      position.token_0.merge!(amount: amounts[:amount_0], fees: fees[:fees_0])
      position.token_1.merge!(amount: amounts[:amount_1], fees: fees[:fees_1])
      position.save!
      position_report.update!(status: :fees_info_fetched)
      call(position_report)
    end

    def calculate_fees(position)
      contract = Blockchain::Arbitrum::PoolContract.new(position.owner)
      tick_lower = contract.ticks(position.tick_lower)
      tick_upper = contract.ticks(position.tick_upper)
      Positions::CalculateFees.new(position, tick_lower, tick_upper).call
    end

    def calculate_amounts(position)
      Positions::CalculateAmounts.new(position).call
    end

    def process_fees_info_fetched_report(position_report)
      Builders::Position::ParsedEvents.new.call(position_report.position)
      position_report.update!(status: :completed)
      call(position_report)
    end
  end
end
