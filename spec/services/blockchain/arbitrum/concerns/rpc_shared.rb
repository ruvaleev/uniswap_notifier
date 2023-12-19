# frozen_string_literal: true

RSpec.shared_context 'with mocked RPC request' do
  let(:response_body) { File.read(fixture_path) }
  let(:rpc_url) { /#{ENV.fetch('ARBITRUM_URL', nil)}/ }

  before do
    stub_request(:post, /#{rpc_url}/).to_return(
      status: 200,
      body: response_body,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end

RSpec.shared_context 'with mocked positions logs' do
  let(:log_1001) do
    {
      'Collect' => [
        {
          'recipient' => '0xc36442b4a4522e871399cd717abdd847ab11fe88',
          'amount0' => 113_170_575_274_402_416,
          'amount1' => 205_450_158_813_346_474_497,
          'blockNumber' => 136_491_756
        },
        {
          'recipient' => '0xc36442b4a4522e871399cd717abdd847ab11fe88',
          'amount0' => 174_685_398_022_183_630,
          'amount1' => 19_802_098_020_191_023_044_861,
          'blockNumber' => 143_631_172
        },
        {
          'recipient' => '0xc36442b4a4522e871399cd717abdd847ab11fe88',
          'amount0' => 243_787_861_813_350_792,
          'amount1' => 19_996_291_262_823_817_704_610,
          'blockNumber' => 153_271_683
        }
      ],
      'DecreaseLiquidity' => [
        {
          'liquidity' => 3_554_109_264_111_449_680_947,
          'amount0' => 23_347_648_059_209_943,
          'amount1' => 19_504_107_716_354_504_615_260,
          'blockNumber' => 143_631_172
        },
        {
          'liquidity' => 1_777_054_632_055_724_840_474,
          'amount0' => 0,
          'amount1' => 19_550_963_125_709_638_997_469,
          'blockNumber' => 153_271_683
        }
      ],
      'IncreaseLiquidity' => [
        {
          'liquidity' => 7_108_218_528_222_899_361_894,
          'amount0' => 28_400_052_060_967_359,
          'amount1' => 39_044_924_814_345_658_556_843,
          'blockNumber' => 132_099_846
        }
      ]
    }
  end
  let(:log_1000) do
    {
      'Collect' => [],
      'DecreaseLiquidity' => [],
      'IncreaseLiquidity' => [
        { 'liquidity' => 386_283_065_283_473, 'amount0' => 0, 'amount1' => 11_950_680_406_515_371_969,
          'blockNumber' => 143_950_419 }
      ]
    }
  end
  let(:collects_1001) do
    [
      {
        block_number: 136_491_756,
        timestamp: 1_696_176_230,
        amount_0: BigDecimal('0.113170575274402416'),
        amount_1: BigDecimal('205.450158813346474497'),
        usd_price_0: BigDecimal('1670.9989557571496'),
        usd_price_1: BigDecimal('0.9074781365453766')
      },
      {
        block_number: 143_631_172,
        timestamp: 1_698_175_159,
        amount_0: BigDecimal('0.17468539802218363'),
        amount_1: BigDecimal('19802.098020191023044861'),
        usd_price_0: BigDecimal('1764.9303085804013'),
        usd_price_1: BigDecimal('0.8809409828037982')
      },
      {
        block_number: 153_271_683,
        timestamp: 1_700_743_351,
        amount_0: BigDecimal('0.243787861813350792'),
        amount_1: BigDecimal('19996.29126282381770461'),
        usd_price_0: BigDecimal('2065.9414413104028'),
        usd_price_1: BigDecimal('1.0203447589097396')
      }
    ]
  end
  let(:liquidity_decreases_1001) do
    [
      {
        block_number: 143_631_172,
        timestamp: 1_698_175_159,
        amount_0: BigDecimal('0.023347648059209943'),
        amount_1: BigDecimal('19504.10771635450461526'),
        usd_price_0: BigDecimal('1764.9303085804013'),
        usd_price_1: BigDecimal('0.8809409828037982'),
        liquidity: 3_554_109_264_111_449_680_947
      },
      {
        block_number: 153_271_683,
        timestamp: 1_700_743_351,
        amount_0: BigDecimal('0'),
        amount_1: BigDecimal('19550.963125709638997469'),
        usd_price_0: BigDecimal('2065.9414413104028'),
        usd_price_1: BigDecimal('1.0203447589097396'),
        liquidity: 1_777_054_632_055_724_840_474
      }
    ]
  end
  let(:liquidity_increases_1001) do
    [
      {
        block_number: 132_099_846,
        timestamp: 1_695_009_234,
        amount_0: BigDecimal('0.028400052060967359'),
        amount_1: BigDecimal('39044.924814345658556843'),
        usd_price_0: BigDecimal('1622.47877705834'),
        usd_price_1: BigDecimal('0.794920572558373'),
        liquidity: 7_108_218_528_222_899_361_894
      }
    ]
  end
  let(:fees_claims_1001) do
    [
      {
        block_number: 136_491_756,
        timestamp: 1_696_176_230,
        amount_0: BigDecimal('0.113170575274402416'),
        amount_1: BigDecimal('205.450158813346474497'),
        usd_price_0: BigDecimal('1670.9989557571496'),
        usd_price_1: BigDecimal('0.9074781365453766'),
        notional_position_usd_value: BigDecimal('31083.69'),
        percent_of_deposit: BigDecimal('1.2082')
      },
      {
        block_number: 143_631_172,
        timestamp: 1_698_175_159,
        amount_0: BigDecimal('0.151337749962973687'),
        amount_1: BigDecimal('297.990303836518429601'),
        usd_price_0: BigDecimal('1764.9303085804013'),
        usd_price_1: BigDecimal('0.8809409828037982'),
        notional_position_usd_value: BigDecimal('31083.69'),
        percent_of_deposit: BigDecimal('1.7038')
      },
      {
        block_number: 153_271_683,
        timestamp: 1_700_743_351,
        amount_0: BigDecimal('0.243787861813350792'),
        amount_1: BigDecimal('445.328137114178707141'),
        usd_price_0: BigDecimal('2065.9414413104028'),
        usd_price_1: BigDecimal('1.0203447589097396'),
        notional_position_usd_value: BigDecimal('15541.845'),
        percent_of_deposit: BigDecimal('6.1643')
      }
    ]
  end
  let(:liquidity_changes_1001) { { '1698175159' => -50, '1700743351' => -50 } }

  include_context 'with mocked RPC request' do
    let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/position_manager/logs/success.json' }
  end
end

RSpec.shared_context 'with mocked block_timestamp' do
  let(:arbitrum_client) { Blockchain::Arbitrum::Client }

  before do
    allow(arbitrum_client).to receive(:block_timestamp).with(132_099_846).and_return(1_695_009_234)
    allow(arbitrum_client).to receive(:block_timestamp).with(136_491_756).and_return(1_696_176_230)
    allow(arbitrum_client).to receive(:block_timestamp).with(143_631_172).and_return(1_698_175_159)
    allow(arbitrum_client).to receive(:block_timestamp).with(153_271_683).and_return(1_700_743_351)
  end
end

RSpec.shared_context 'with mocked Coingecko::GetHistoricalPrice' do
  let(:get_price_service_double) { instance_double(Coingecko::GetHistoricalPrice) }

  before do
    allow(Coingecko::GetHistoricalPrice).to receive(:new).and_return(get_price_service_double)
    allow(get_price_service_double).to receive(:call)
      .with('WETH', '2023-09-18'.to_date).and_return(BigDecimal('1622.47877705834'))
    allow(get_price_service_double).to receive(:call)
      .with('ARB', '2023-09-18'.to_date).and_return(BigDecimal('0.794920572558373'))
    allow(get_price_service_double).to receive(:call)
      .with('WETH', '2023-10-01'.to_date).and_return(BigDecimal('1670.9989557571496'))
    allow(get_price_service_double).to receive(:call)
      .with('ARB', '2023-10-01'.to_date).and_return(BigDecimal('0.9074781365453766'))
    allow(get_price_service_double).to receive(:call)
      .with('WETH', '2023-10-24'.to_date).and_return(BigDecimal('1764.9303085804013'))
    allow(get_price_service_double).to receive(:call)
      .with('ARB', '2023-10-24'.to_date).and_return(BigDecimal('0.8809409828037982'))
    allow(get_price_service_double).to receive(:call)
      .with('WETH', '2023-11-23'.to_date).and_return(BigDecimal('2065.9414413104028'))
    allow(get_price_service_double).to receive(:call)
      .with('ARB', '2023-11-23'.to_date).and_return(BigDecimal('1.0203447589097396'))
  end
end

RSpec.shared_examples 'raises proper error when RPC request is unsuccessful' do
  context 'when contract returned unsuccessful response' do
    let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/pool_contract/error_32602.json' }
    let(:error_message) { 'invalid argument 0: hex string has length 42, want 40 for common.Address' }

    it 'makes proper request and returns proper response' do
      expect { subject }.to raise_error(IOError, error_message)
    end
  end
end
