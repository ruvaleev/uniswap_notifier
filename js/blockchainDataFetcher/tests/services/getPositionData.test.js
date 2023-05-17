const { ethers } = require('ethers');
const { getPositionData } = require('../../services/getPositionData');

jest.mock('ethers');

describe('getPositionData', () => {
  const validTokenId = 1000;
  const errorText = 'execution reverted: "Invalid token ID" (action="call", data="0x08c379a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000010496e76616c696420746f6b656e20494400000000000000000000000000000000", reason="Invalid token ID", transaction={ "data": "0x99fbab880000000000000000000000000000000000000000000000000000000000000000", "to": "0xC36442b4a4522E871399CD717aBDD847Ab11FE88" }, invocation=null, revert={ "args": [ "Invalid token ID" ], "name": "Error", "signature": "Error(string)" }, code=CALL_EXCEPTION, version=6.3.0)';
  const poolAddress = '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d';
  const mockPositionData = {
    token0: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
    token1: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
    fee: BigInt(3000),
    tickLower: BigInt(-201960),
    tickUpper: BigInt(-188100),
    liquidity: BigInt(176562249908)
  };
  let positionManager;

  beforeAll(() => {
    positionManager = {
      positions: jest.fn().mockImplementation((tokenId) => {
        if (tokenId !== validTokenId) {
          throw new Error(errorText);
        }

        return mockPositionData
      })
    };
    const factory = {
      getPool: jest.fn().mockImplementation(() => Promise.resolve(poolAddress))
    };
    const factoryAddress = '0x1F98431c8aD98523631AE4a59f267346ea31F984';

    ethers.Contract = jest.fn().mockImplementation((address) => {
      if (address === factoryAddress) {
        return factory
      } else {
        return positionManager
      }
    });
  });

  afterAll(() => {
    jest.clearAllMocks();
  });

  describe('when valid tokenId has been provided', () => {
    const tokenId = validTokenId;

    it('requests data from uniswap and returns serialized data', async () => {
      const expectedPositionData = {
        token0: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
        token1: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
        fee: 3000,
        tickLower: -201960,
        tickUpper: -188100,
        liquidity: '176562249908',
        poolAddress: poolAddress
      }

      const positionData = await getPositionData(tokenId);

      expect(positionManager.positions).toHaveBeenCalledWith(tokenId);
      expect(positionData).toEqual(expectedPositionData);
    });
  })

  describe('when invalid tokenId has been provided', () => {
    const tokenId = 'invalidTokenId';

    it('returns proper error', async () => {
      await expect(getPositionData(tokenId)).rejects.toThrow(new Error(errorText));
    })
  })
});
