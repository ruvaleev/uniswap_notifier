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
  }, 15000);

  afterAll(() => {
    server.kill();
  });

  describe('GetTokenData', () => {
    it('returns proper response when request contains valid address', async () => {
      const testCheck = () => new Promise((resolve, reject) => {
        client.GetTokenData({address: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'}, (err, response) => {
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

    it('returns an error when request contains invalid address', async () => {
      const testCheck = () => new Promise((resolve, reject) => {
        client.GetTokenData({address: '1xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'}, (err) => {
          if (err) {
            resolve(err);
          } else {
            reject(new Error('Expected method to return error'));
          }
        });
      });
      const expectedErrorMessage = '2 UNKNOWN: missing revert data (action="call", data=null, reason=null, transaction={ "data": "0x0178b8bffc93a03a294172681ef8cc8d75bc6dd7a48d53bd79d83739ae43724ccd36c647", "to": "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e" }, invocation=null, revert=null, code=CALL_EXCEPTION, version=6.3.0)';

      const error = await testCheck();

      expect(error).toBeDefined();
      expect(error.message).toEqual(expectedErrorMessage);
    });
  });

  describe('GetPositionData', () => {
    it('returns proper response when request contains valid id', async () => {
      const testCheck = () => new Promise((resolve, reject) => {
        client.GetPositionData({id: 1000}, (err, response) => {
          if (err) {
            reject(err);
          } else {
            resolve(response);
          }
        });
      });

      const response = await testCheck();

      expect(response.token0).toEqual('0x82aF49447D8a07e3bd95BD0d56f35241523fBab1');
      expect(response.token1).toEqual('0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8');
      expect(response.fee).toEqual(3000);
      expect(response.tickLower).toEqual(-201960);
      expect(response.tickUpper).toEqual(-188100);
      expect(response.liquidity).toEqual('176562249908');
      expect(response.poolAddress).toEqual('0x17c14D2c404D167802b16C450d3c99F88F2c4F4d');
    });

    it('returns an error when request contains invalid id', async () => {
      const testCheck = () => new Promise((resolve, reject) => {
        client.GetPositionData({id: 0}, (err) => {
          if (err) {
            resolve(err);
          } else {
            reject(new Error('Expected method to return error'));
          }
        });
      });
      const expectedErrorMessage = '2 UNKNOWN: execution reverted: "Invalid token ID" (action="call", data="0x08c379a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000010496e76616c696420746f6b656e20494400000000000000000000000000000000", reason="Invalid token ID", transaction={ "data": "0x99fbab880000000000000000000000000000000000000000000000000000000000000000", "to": "0xC36442b4a4522E871399CD717aBDD847Ab11FE88" }, invocation=null, revert={ "args": [ "Invalid token ID" ], "name": "Error", "signature": "Error(string)" }, code=CALL_EXCEPTION, version=6.3.0)'
      const error = await testCheck();

      expect(error).toBeDefined();
      expect(error.message).toEqual(expectedErrorMessage);
    });
  });

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
    const invalidToken = {
      address: '1x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
      decimals: 18,
      symbol: 'WETH',
      name: 'Invalid Ether'
    }

    it('returns proper response when request contains valid inputData', async () => {
      const inputData = {
        poolAddress: '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d',
        chainId: 42161,
        token0: token0,
        token1: token1,
        fee: 3000,
        tickLower: -201960,
        tickUpper: -188100,
        positionLiquidity: '176562249908'
      }

      const testCheck = () => new Promise((resolve, reject) => {
        client.GetPoolState(inputData, (err, response) => {
          if (err) {
            reject(err);
          } else {
            resolve(response);
          }
        });
      });

      const response = await testCheck();

      expect(response.token0.address).toEqual(token0.address);
      expect(typeof(response.token0.amount)).toBe('string');
      expect(typeof(response.token0.price)).toBe('string');
      expect(response.token1.address).toEqual(token1.address);
      expect(typeof(response.token1.amount)).toBe('string');
      expect(typeof(response.token1.price)).toBe('string');
    });

    it('returns an error when request contains invalid inputData', async () => {
      const inputData = {
        poolAddress: '0x17c14D2c404D167802b16C450d3c99F88F2c4F4d',
        chainId: 42161,
        token0: invalidToken,
        token1: token1,
        fee: 3000,
        tickLower: -201960,
        tickUpper: -188100,
        positionLiquidity: '176562249908'
      }

      const testCheck = () => new Promise((resolve, reject) => {
        client.GetPoolState(inputData, (err) => {
          if (err) {
            resolve(err);
          } else {
            reject(new Error('Expected method to return error'));
          }
        });
      });
      const expectedErrorMessage = '2 UNKNOWN: 1x82aF49447D8a07e3bd95BD0d56f35241523fBab1 is not a valid address.'
      const error = await testCheck();

      expect(error).toBeDefined();
      expect(error.message).toEqual(expectedErrorMessage);
    });
  });
})
