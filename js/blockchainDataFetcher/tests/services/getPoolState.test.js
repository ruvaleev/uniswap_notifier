const { ethers } = require('ethers');

const { getPoolState } = require('../../services/getPoolState');

jest.mock('ethers');

describe('getPoolState', () => {
  const token0 = {
    address: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
    decimals: 18,
    symbol: 'WETH',
    name: 'Wrapped Ether'
  }
  const token1 = {
    address: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
    decimals: 6,
    symbol: 'USDC',
    name: 'USD Coin (Arb1)'
  }
  const inputData = [42161, token0, token1, 3000, -201960, -188100, '176562249908']
  const errorText = 'bad address checksum (argument="address", value="0x82aF49447D8a07e3bd95BD0d56f35241523fBab0", code=INVALID_ARGUMENT, version=6.3.0)'

  beforeAll(() => {
      const factory = {
        getPool: jest.fn().mockImplementation((token0Address) => {
          if (token0Address !== token0.address) {
            throw new TypeError(errorText);
          }

          Promise.resolve('0xPoolAddress')
        })
      };
      const factoryAddress = '0x1F98431c8aD98523631AE4a59f267346ea31F984';

      const poolContract = {
        liquidity: jest.fn().mockReturnValue(
          Promise.resolve(
            BigInt('846306045530175447')
          )
        ),
        slot0: jest.fn().mockReturnValue(
          Promise.resolve(
            {
              sqrtPriceX96: BigInt('3356942378967352067072233'),
              tick: BigInt(-201392)
            }
          )
        ),
      }

      ethers.Contract = jest.fn().mockImplementation((address) => {
        if (address === factoryAddress) {
          return factory
        } else {
          return poolContract
        }
      });
  });

  describe('with valid inputData', () => {
    it('returns correct data', async () => {
      const result = await getPoolState(...inputData);

      expect(result).toEqual({
        token0: {
          address: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
          decimals: 18,
          symbol: 'WETH',
          name: 'Wrapped Ether',
          amount: '0.002023054661504617',
          price: '1795.27',
        },
        token1: {
          address: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
          decimals: 6,
          symbol: 'USDC',
          name: 'USD Coin (Arb1)',
          amount: '0.209753',
          price: '0.000557021',
        }
      });
    });
  })

  describe('with invalid inputData', () => {
    it('returns proper error', async () => {
      const invalidToken = {
        address: 'invalidAddress',
        decimals: 18,
        symbol: 'WETH',
        name: 'Wrapped Ether'
      }
      const invalidInputData = [42161, invalidToken, token1, 3000, -201960, -188100, '176562249908'];

      await expect(getPoolState(...invalidInputData)).rejects.toThrow(new TypeError(errorText));
    });
  })
});
