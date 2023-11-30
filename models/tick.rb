# frozen_string_literal: true

class Tick
  attr_accessor :fee_growth_outside_0_x_128, :fee_growth_outside_1_x_128

  def initialize(fee_growth_outside_0_x_128, fee_growth_outside_1_x_128)
    @fee_growth_outside_0_x_128 = BigDecimal(fee_growth_outside_0_x_128)
    @fee_growth_outside_1_x_128 = BigDecimal(fee_growth_outside_1_x_128)
  end
end
