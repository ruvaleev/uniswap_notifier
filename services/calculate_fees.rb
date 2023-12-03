# frozen_string_literal: true

class CalculateFees
  Q128 = BigDecimal(2)**128
  Q256 = BigDecimal(2)**256

  attr_reader :position, :current_tick, :fee_growth_global_0, :fee_growth_global_1, :tick_lower, :tick_upper

  def initialize(position, tick_lower, tick_upper)
    @position = position
    @tick_lower = tick_lower
    @tick_upper = tick_upper
    @current_tick = position.pool['tick'].to_i
    @fee_growth_global_0 = BigDecimal(position.pool['feeGrowthGlobal0X128'])
    @fee_growth_global_1 = BigDecimal(position.pool['feeGrowthGlobal1X128'])
  end

  def call
    outside = calculate_fees_out_of_range
    within_range_0, within_range_1 = calculate_fees_within_range(outside[:above], outside[:below])
    uncollected_fees_0, uncollected_fees_1 = calculate_uncollected_fees(within_range_0, within_range_1)

    {
      fees_0: human_readable_fees(uncollected_fees_0, position.token_0['decimals']),
      fees_1: human_readable_fees(uncollected_fees_1, position.token_1['decimals'])
    }
  end

  private

  def calculate_fees_out_of_range
    {
      above: fees_out_of_range(current_tick < position.tick_upper, tick_upper),
      below: fees_out_of_range(current_tick >= position.tick_lower, tick_lower)
    }
  end

  def fees_out_of_range(is_in_range, tick_info)
    if is_in_range
      [tick_info.fee_growth_outside_0_x_128, tick_info.fee_growth_outside_1_x_128]
    else
      [
        sub_in_256(fee_growth_global_0, tick_info.fee_growth_outside_0_x_128),
        sub_in_256(fee_growth_global_1, tick_info.fee_growth_outside_1_x_128)
      ]
    end
  end

  def calculate_fees_within_range(fees_above, fees_below)
    [
      fees_within_range(fee_growth_global_0, fees_below[0], fees_above[0]),
      fees_within_range(fee_growth_global_1, fees_below[1], fees_above[1])
    ]
  end

  def fees_within_range(fees_global, fees_below, fees_above)
    sub_in_256(sub_in_256(fees_global, fees_below), fees_above)
  end

  def calculate_uncollected_fees(fees_within_range_0, fees_within_range_1)
    [
      uncollected_fees(position.liquidity, fees_within_range_0, position.fee_growth_inside_last_x128_0),
      uncollected_fees(position.liquidity, fees_within_range_1, position.fee_growth_inside_last_x128_1)
    ]
  end

  def uncollected_fees(liquidity, fees_within_range, fees_recorded)
    fees_not_recorded = sub_in_256(fees_within_range, fees_recorded)
    liquidity * (fees_not_recorded / Q128)
  end

  def human_readable_fees(value, decimals)
    precision = 10**decimals
    (value / precision).round(decimals)
  end

  def sub_in_256(minuend, subtrahend)
    diff = minuend - subtrahend
    diff.negative? ? (Q256 + diff) : diff
  end
end
