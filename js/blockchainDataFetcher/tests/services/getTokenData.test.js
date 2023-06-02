require('dotenv').config();

const { getTokenData } = require('../../services/getTokenData');

const validContractAddress = '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'
const errorText = 'missing revert data (action="call", data=null, reason=null, transaction={ "data": "0x0178b8bf972ab860ff8ae82dc50129430e9590031415d057206ce6c135c3b1954112721c", "to": "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e" }, invocation=null, revert=null, code=CALL_EXCEPTION, version=6.3.0)'

jest.mock('ethers', () => {
  const providerStub = jest.fn();

  return {
    ethers: {
      JsonRpcProvider: jest.fn((providerAddress) => providerAddress == process.env.INFURA_PROVIDER_URL && providerStub),
      Contract: jest.fn().mockImplementation((address, abi, provider) => {
        if (address !== validContractAddress || provider !== providerStub) {
          throw new Error(errorText);
        }

        return {
          name: {
            staticCall: jest.fn().mockResolvedValue('Expected Token Name'),
          },
          symbol: {
            staticCall: jest.fn().mockResolvedValue('Expected Token Symbol'),
          },
          decimals: {
            staticCall: jest.fn().mockResolvedValue(18),
          },
        }
      }),
    },
  };
});

describe('getTokenData', () => {
  let contractAddress;

  describe('when provied valid contractAddress', () => {
    beforeEach(() => {
      contractAddress = validContractAddress
    })

    it('returns correct token data', async () => {
      const tokenData = await getTokenData(contractAddress);

      expect(tokenData).toEqual({
        name: 'Expected Token Name',
        symbol: 'Expected Token Symbol',
        decimals: 18,
      });
    });
  })

  describe('when provied invalid contractAddress', () => {
    beforeEach(() => {
      contractAddress = 'invalidContractAddress'
    })

    it('returns proper error', async () => {
      await expect(getTokenData('invalidContractAddress')).rejects.toThrow(new Error(errorText));
    });
  })
});
