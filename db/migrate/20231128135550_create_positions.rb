# frozen_string_literal: true

class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      # NOT CHANGING
      t.integer :uniswap_id, index: { unique: true }
      t.integer :initial_tick
      t.timestamp :initial_timestamp
      t.string :owner # Use relateion
      t.integer :tick_lower
      t.integer :tick_upper
      # CHANGING
      t.decimal :fee_growth_inside_last_x128_0
      t.decimal :fee_growth_inside_last_x128_1
      t.decimal :liquidity
      t.jsonb :liquidity_changes, null: false, default: {}
      t.jsonb :token_0, null: false, default: {}
      t.jsonb :token_1, null: false, default: {}
      t.jsonb :pool, null: false, default: {}
      t.jsonb :events, null: false, default: {}
      t.jsonb :fees_claims, null: false, default: {}
      # Кажется, это не надо хранить в базе данных:
      # t.decimal :totalUsdValue
    end
  end
end
__END__
{
  amountCollectedUSD: "18219.86982107978947108542096607791",
  amountDepositedUSD: "31768.82952191150824041591381546829",
  amountWithdrawnUSD: "17302.55256597414346756880529927819",
  collectedFeesToken0: "0.264508325237376103",
  collectedFeesToken1: "503.440462649864904098",
  collectedToken0: "0.287855973296586046",
  collectedToken1: "20007.548179004369519358",
  daysAge: 53,
  depositedToken0: "0.028400052060967359",
  depositedToken1: "39044.924814345658556843",
  feeGrowthInside0LastX128: "76397129572731229585273990554861353",
  feeGrowthInside1LastX128: "131266988962904009232919193323370292802",
  id: "100000",
  initialTick: "76046",
  initialTimestamp: 1698260190,
  liquidity: "3554109264111449680947",
  liquidityChanges: {
    '1698175159': '-50'
  },
  owner: "0x5eeefdac5a68d3117994bd8cec068cc3fb3bc402",
  tickLower: "73430",
  tickUpper: "76050",
  withdrawnToken0: "0.023347648059209943",
  withdrawnToken1: "19504.10771635450461526",
  token0: {
    decimal: "18",
    id: "0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    symbol: "WETH",
    amount: BigNumber("6.252150962732637"),
    initialAmount: BigNumber("0.028400052060967359"),
    fees: BigNumber("0.105978455624063704"),
    price: BigNumber("1724.839538208308673783"),
    maxPrice: BigNumber("2007.448467185575736949"),
    minPrice: BigNumber("1544.773960081565292057"),
    usdPrice: 1891.06,
    usdValue: BigNumber("11823.19259958518052522"),
    usdFees: BigNumber("200.41161829244190808624"),
    holdUsdValue: BigNumber("26.85310122520646695527")
  },
  token1: {
    decimal: "18",
    id: "0x912ce59144191c1204e64559fe8253a0e49e6548",
    symbol: "ARB",
    amount: BigNumber("7917.044869547772"),
    initialAmount: BigNumber("39044.924814345658556843"),
    fees: BigNumber("189.402873985428375334"),
    price: BigNumber("0.000579764075352052"),
    maxPrice: BigNumber("0.000498144792429960"),
    minPrice: BigNumber("0.000647343900040365"),
    usdPrice: 1.096,
    usdValue: BigNumber("8677.081177024358112"),
    usdFees: BigNumber("207.585549888029499366064"),
    holdUsdValue: BigNumber("21396.618798261420889149964")
  },
  pool: {
    id: "0xc6f780497a95e246eb9449f5e4770916dcd6396a",
    tick: "74532",
    sqrtPrice: "3290439675567831381444062416141"
  },
  events: {
    collects: [
      {
        amount0: '0.113170575274402416',
        amount1: '205.450158813346474497',
        blockNumber: 136491756,
        timestamp: 1696176230,
        usdPrice0: '1600',
        usdPrice1: '1',
      },
      {
        amount0: '0.17468539802218363',
        amount1: '19802.098020191023044861',
        blockNumber: 143631172,
        timestamp: 1698175159,
        usdPrice0: '1650',
        usdPrice1: '0.95',
      }
    ],
    liquidityIncreases: [
      {
        liquidity: '7108218528222899361894',
        amount0: '0.028400052060967359',
        amount1: '39044.924814345658556843',
        blockNumber: 132099846,
        timestamp: 1695009234,
        usdPrice0: '1700',
        usdPrice1: '0.90',
      }
    ],
    liquidityDecreases: [
      {
        liquidity: "1777054632055724840473",
        amount0: "0.011673824029604971",
        amount1: "9752.053858177253",
        blockNumber: 143631172,
        timestamp: 1698175159,
        usdPrice0: '1650',
        usdPrice1: '0.95',
      },
      {
        liquidity: "1777054632055724840474",
        amount0: "0.011673824029604972",
        amount1: "9752.053858177253",
        blockNumber: 143631172,
        timestamp: 1698175159,
        usdPrice0: '1650',
        usdPrice1: '0.95',
      }
    ]
  },
  feesClaims: [
    {
      "amount0": BigNumber("0.113170575274402416"),
      "amount1": BigNumber("205.450158813346474497"),
      "timestamp": "1696176230",
      "usdAmount0": BigNumber("181.0729204390438656"),
      "usdAmount1": BigNumber("205.450158813346474497"),
      "percentOfDeposit": BigNumber("1.21667396963995391451"),
    },
    {
      "amount0": BigNumber("0.151337749962973687"),
      "amount1": BigNumber("297.990303836518429601"),
      "timestamp": "1698175159",
      "usdAmount0": BigNumber("249.70728743890658355"),
      "usdAmount1": BigNumber("283.09078864469250812095"),
      "percentOfDeposit": BigNumber("1.6771095570773791882"),
    }
  ],
  totalUsdValue: BigNumber("20500.27377660953863722")
}
