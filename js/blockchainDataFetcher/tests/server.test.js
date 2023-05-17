const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const server = require('../server');
const { getTokenData } = require('../services/getTokenData');
const { getPositionData } = require('../services/getPositionData');

jest.mock('../services/getTokenData');
jest.mock('../services/getPositionData');

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
        liquidity: '176562249908'
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
});
