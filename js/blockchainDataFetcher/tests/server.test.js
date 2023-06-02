const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const server = require('../server');
const { getTokenData } = require('../services/getTokenData');
const { getPositionData } = require('../services/getPositionData');
const { getPoolState } = require('../services/getPoolState');

jest.mock('../services/getTokenData');
jest.mock('../services/getPositionData');
jest.mock('../services/getPoolState');

const PROTO_PATH = '../../protos/blockchain_data_fetcher.proto';

const packageDefinition = protoLoader.loadSync(
  PROTO_PATH,
  {keepCase: true, longs: String, enums: String, defaults: true, oneofs: true}
);

const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);

const client = new protoDescriptor.BlockchainDataFetcher(
  'localhost:50051',
  grpc.credentials.createInsecure(),
);

describe('BlockchainDataFetcher service', () => {
  beforeAll(() => {
    return new Promise((resolve, reject) => {
      server.bindAsync(
        'localhost:50051',
        grpc.ServerCredentials.createInsecure(),
        (err) => {
          if (err) {
            reject(err);
          } else {
            server.start();
            resolve();
          }
        },
      );
    });
  });

  afterAll(() => {
    server.forceShutdown();
  });

  describe('GetTokenData', () => {
    // eslint-disable-next-line jest/no-done-callback
    it('returns correct token data', (done) => {
      const mockTokenData = {
        name: 'Expected Token Name',
        symbol: 'Expected Token Symbol',
        decimals: 18,
      };

      getTokenData.mockResolvedValue(mockTokenData);

      client.GetTokenData({ address: '0x123' }, (error, response) => {
        expect(response).toEqual(mockTokenData);
        done();
      });
    });

    // eslint-disable-next-line jest/no-done-callback
    it('throws error for invalid contract address', (done) => {
      getTokenData.mockRejectedValue(new Error('Invalid contract address'));

      client.GetTokenData({ address: 'invalid' }, (error) => {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toEqual('2 UNKNOWN: Invalid contract address');
        done();
      });
    });
  })

  describe('GetPositionData', () => {
    // eslint-disable-next-line jest/no-done-callback
    it('returns correct position data', (done) => {
      const mockPositionData = {
        token0: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
        token1: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
        fee: 3000,
        tickLower: -201960,
        tickUpper: -188100,
        liquidity: '176562249908',
        poolAddress: '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d'
      };

      getPositionData.mockResolvedValue(mockPositionData);

      client.GetPositionData({ id: 1000 }, (error, response) => {
        expect(response).toEqual(mockPositionData);
        done();
      });
    });

    // eslint-disable-next-line jest/no-done-callback
    it('throws error for invalid id', (done) => {
      getPositionData.mockRejectedValue(new Error('Invalid position id'));

      client.GetPositionData({ id: 'invalid' }, (error) => {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toEqual('2 UNKNOWN: Invalid position id');
        done();
      });
    });
  })

  describe('GetPoolState', () => {
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
    const input = {
      chainId: 42161,
      token0: token0,
      token1: token1,
      fee: 3000,
      tickLower: -201960,
      tickUpper: -188100,
      positionLiquidity: '176562249908',
      poolAddress: '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d'
    }

    // eslint-disable-next-line jest/no-done-callback
    it('returns correct position data', (done) => {
      const mockPoolState = {
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
      };

      getPoolState.mockResolvedValue(mockPoolState);

      client.GetPoolState(input, (error, response) => {
        expect(response).toEqual(mockPoolState);
        done();
      });
    });

    // eslint-disable-next-line jest/no-done-callback
    it('throws error for invalid inputData', (done) => {
      getPoolState.mockRejectedValue(new Error('Invalid input data'));

      client.GetPoolState({...input, chainId: 0}, (error) => {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toEqual('2 UNKNOWN: Invalid input data');
        done();
      });
    });
  })
});
