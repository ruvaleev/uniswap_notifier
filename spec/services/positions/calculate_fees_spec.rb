# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Positions::CalculateFees do
  describe '#call' do
    subject(:call_service) { service.call }

    let(:service) { described_class.new(position, tick_lower, tick_upper) }
    let(:position) { build(:position, **position_params) }

    context 'with same decimals' do
      let(:position_params) do
        {
          fee_growth_inside_last_x128_0: BigDecimal('69152337145849472040338377168383236'),
          fee_growth_inside_last_x128_1: BigDecimal('117001692319817971649209116374655145049'),
          liquidity: BigDecimal('7108218528222899361894'),
          tick_lower: 73_430,
          tick_upper: 76_050,
          token_0: { 'decimals' => 18 },
          token_1: { 'decimals' => 18 },
          pool: {
            'tick' => '75677',
            'feeGrowthGlobal0X128' => '208835107267699315514338644992581187',
            'feeGrowthGlobal1X128' => '313653298461314658420682448261369158520'
          }
        }
      end
      let(:tick_lower) { Tick.new('129362448994648287540025458230935296', '175943338775698876993679593052051410691') }
      let(:tick_upper) { Tick.new('6870750798044025148227866664355024', '14013529065654888970332476500856001847') }
      let(:fees_0) { BigDecimal('0.07205868452720207') }
      let(:fees_1) { BigDecimal('139.847572053993475231') }

      it { is_expected.to eq({ fees_0:, fees_1: }) }
    end

    context 'with different decimals' do
      let(:position_params) do
        {
          fee_growth_inside_last_x128_0: BigDecimal('33819274971982470552721340282569211455911'),
          fee_growth_inside_last_x128_1: BigDecimal('58577573406703228483069725719999'),
          liquidity: BigDecimal('477550033551699'),
          tick_lower: -203_190,
          tick_upper: -200_310,
          token_0: { 'decimals' => 18 },
          token_1: { 'decimals' => 6 },
          pool: {
            'tick' => '-202779',
            'feeGrowthGlobal0X128' => '38801535727909269532917328293691613330053',
            'feeGrowthGlobal1X128' => '66815283213268741772954215092612'
          }
        }
      end
      let(:tick_lower) { Tick.new('1389446086837536329373633889581184202797', '2477092305229384387505363697019') }
      let(:tick_upper) { Tick.new('302262195143298415259619494746838407729', '612076910341715108280663452272') }
      let(:fees_0) { BigDecimal('0.004617939679200664') }
      let(:fees_1) { BigDecimal('7.225428') }

      it { is_expected.to eq({ fees_0:, fees_1: }) }
    end

    context 'when current tick is out of range' do
      let(:position_params) do
        {
          fee_growth_inside_last_x128_0:
            BigDecimal('115792089237316195423570985008687907848111843853796435050067843230047949334441'),
          fee_growth_inside_last_x128_1:
            BigDecimal('115792089237316195423570985008687907853269984656885367027568119608456871195988'),
          liquidity: BigDecimal('16649031368038418'),
          tick_lower: -202_950,
          tick_upper: -202_740,
          token_0: { 'decimals' => 18 },
          token_1: { 'decimals' => 6 },
          pool: {
            'tick' => '-202710',
            'feeGrowthGlobal0X128' => '41587826366351661761787568234919597257287',
            'feeGrowthGlobal1X128' => '71207135789803872127732583284281'
          }
        }
      end
      let(:tick_lower) { Tick.new('28138940083802386376225608139418141010216', '49574638000242573396812064032056') }
      let(:tick_upper) { Tick.new('23623927678635026405525201674516592214499', '41889215130226370061098949950347') }
      let(:fees_0) { BigDecimal('0.031466411596125633') }
      let(:fees_1) { BigDecimal('52.340953') }

      it { is_expected.to eq({ fees_0:, fees_1: }) }
    end
  end
end
