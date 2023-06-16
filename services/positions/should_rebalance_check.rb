# frozen_string_literal: true

module Positions
  class ShouldRebalanceCheck
    def call(current_tick:, lower_tick:, upper_tick:, threshold:)
      threshold_value = threshold * (upper_tick - lower_tick) / 100
      current_tick + threshold_value >= upper_tick ||
        current_tick - threshold_value <= lower_tick
    end
  end
end
