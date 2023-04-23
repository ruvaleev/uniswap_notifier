# frozen_string_literal: true

puts 'Currencies:'
codes = %w[ada algo atom avax bnb btc btc.b bch dai dot eth ftm gmx link ltc sol trx uni usdc usdt wbtc weth]
codes.each do |code|
  Currency.find_or_create_by(code:)
end
puts 'Currencies has been created'
