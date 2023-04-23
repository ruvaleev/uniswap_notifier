# frozen_string_literal: true

module CoinGecko
  class CoinId
    def call(code)
      coingecko_ids(code.downcase)
    end

    private

    def coingecko_ids(code) # rubocop:disable Metrics/MethodLength
      {
        'ada' => 'cardano',
        'algo' => 'algorand',
        'atom' => 'cosmos',
        'avax' => 'avalanche-2',
        'bnb' => 'binancecoin',
        'btc' => 'bitcoin',
        'btc.b' => 'bitcoin-avalanche-bridged-btc-b',
        'bch' => 'bitcoin-cash',
        'dai' => 'dai',
        'dot' => 'polkadot',
        'eth' => 'ethereum',
        'ftm' => 'fantom',
        'gmx' => 'gmx',
        'link' => 'chainlink',
        'ltc' => 'litecoin',
        'sol' => 'solana',
        'trx' => 'tron',
        'uni' => 'uniswap',
        'usdc' => 'usd-coin',
        'usdt' => 'tether',
        'wbtc' => 'wrapped-bitcoin',
        'weth' => 'weth'
      }[code]
    end
  end
end
