# frozen_string_literal: true

module EventParseable
  private

  def overall_usd_amount(log)
    (
      (log[:amount_0] * log[:usd_price_0]) + (log[:amount_1] * log[:usd_price_1])
    ).round(2)
  end
end
