# frozen_string_literal: true

FactoryBot.define do
  factory :position, class: 'Reports::Position' do
    association :portfolio_report
    tick_lower { rand(100_000..200_000) }
    tick_upper { rand(300_000..400_000) }
    token_0 { { symbol: 'WETH', decimals: 18, id: '0x82af49447d8a07e3bd95bd0d56f35241523fbab1' } }
    token_1 { { symbol: 'ARB', decimals: 18, id: '0x912ce59144191c1204e64559fe8253a0e49e6548' } }
    sequence(:uniswap_id) { |i| i }
  end
end
