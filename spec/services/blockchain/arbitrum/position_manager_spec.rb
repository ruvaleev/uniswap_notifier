# frozen_string_literal: true

require './spec/spec_helper'
require_relative './concerns/rpc_shared'

RSpec.describe Blockchain::Arbitrum::PositionManager do
  let(:contract) { described_class.new }

  describe '#logs' do
    subject(:logs) { contract.logs(*position_ids) }

    let(:position_ids) { [1000, 1001] }
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
            'liquidity' => 3_554_109_264_111_449_680_947,
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

    include_context 'with mocked RPC request' do
      let(:fixture_path) { 'spec/fixtures/blockchain/arbitrum/position_manager/logs/success.json' }
    end

    it 'returns properly serialized hash with logs' do
      expect(logs).to eq({ 1000 => log_1000, 1001 => log_1001 })
    end

    it_behaves_like 'raises proper error when RPC request is unsuccessful'
  end
end
