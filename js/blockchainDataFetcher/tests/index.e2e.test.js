const { spawn } = require('child_process');
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const PROTO_PATH = '../../protos/blockchain_data_fetcher.proto';

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true
});

const tokenProto = grpc.loadPackageDefinition(packageDefinition).BlockchainDataFetcher;

let server;
let client;

async function waitForServer(testCheck, maxRetries = 10, delay = 500) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      // The testCheck function should throw an error if the server is not ready.
      await testCheck();
      // If we reach this line without throwing an error, the server is ready.
      return;
    } catch (error) {
      // If we caught an error, the server isn't ready yet.
      // Wait for the specified delay before trying again.
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Server did not start within expected time');
}

describe('runs server, accepts and correctly handles requests', () => {
  beforeAll(async () => {
    server = spawn('node', ['index.js']);
    client = new tokenProto('localhost:50051', grpc.credentials.createInsecure());

    const testCheck = () => new Promise((resolve, reject) => {
      client.GetTokenData({'address': '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'}, (err, response) => {
        if (err) {
          reject(err);
        } else {
          resolve(response);
        }
      });
    });

    await waitForServer(testCheck);
  }, 10000);

  afterAll(() => {
    server.kill();
  });

  it('returns proper response when request contains valid address', async () => {
    const testCheck = () => new Promise((resolve, reject) => {
      client.GetTokenData({'address': '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'}, (err, response) => {
        if (err) {
          reject(err);
        } else {
          resolve(response);
        }
      });
    });

    const response = await testCheck();

    expect(response.name).toEqual('Tether USD');
    expect(response.symbol).toEqual('USDT');
    expect(response.decimals).toEqual(6);
  });
})
