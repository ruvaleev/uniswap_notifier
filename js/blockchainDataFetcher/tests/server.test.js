const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const server = require('../server');
const { getTokenData } = require('../services/getTokenData');

jest.mock('../services/getTokenData');

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

  // eslint-disable-next-line jest/no-done-callback
  it('GetTokenData returns correct token data', (done) => {
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
  it('GetTokenData throws error for invalid contract address', (done) => {
    getTokenData.mockRejectedValue(new Error('Invalid contract address'));

    client.GetTokenData({ address: 'invalid' }, (error) => {
      expect(error).toBeInstanceOf(Error);
      expect(error.message).toEqual('2 UNKNOWN: Invalid contract address');
      done();
    });
  });
});
