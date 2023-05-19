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
  const poolAddress = '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d'
  const inputData = [poolAddress, 42161, token0, token1, 3000, -201960, -188100, '176562249908']

  beforeAll(() => {
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

      ethers.Contract = jest.fn().mockImplementation(() => poolContract);
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
          minPrice: '1696.0051427274943',
          maxPrice: '6781.55396625618'
        },
        token1: {
          address: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
          decimals: 6,
          symbol: 'USDC',
          name: 'USD Coin (Arb1)',
          amount: '0.209753',
          price: '0.000557021',
          minPrice: '0.0005896208536206515',
          maxPrice: '0.00014745882801726922'
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
      const invalidInputData = [poolAddress, 42161, invalidToken, token1, 3000, -201960, -188100, '176562249908'];

      await expect(getPoolState(...invalidInputData)).rejects.toThrow(new TypeError('invalidAddress is not a valid address.'));
    });
  })
});
