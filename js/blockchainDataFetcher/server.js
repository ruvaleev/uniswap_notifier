const protoLoader = require('@grpc/proto-loader');
const grpc = require('@grpc/grpc-js');

const { getTokenData } = require('./services/getTokenData')
const { getPositionData } = require('./services/getPositionData')
const { getPoolState } = require('./services/getPoolState')

const PROTO_PATH = './protos/blockchain_data_fetcher.proto';

const packageDefinition = protoLoader.loadSync(
  PROTO_PATH,
  {keepCase: true, longs: String, enums: String, defaults: true, oneofs: true}
);
const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);

const { BlockchainDataFetcher } = protoDescriptor;

const server = new grpc.Server();

server.addService(BlockchainDataFetcher.service, {
  GetTokenData: async (call, callback) => {
    const { address } = call.request;
    try {
      const tokenData = await getTokenData(address);
      callback(null, tokenData);
    } catch (error) {
      callback(error);
    }
  },
  GetPositionData: async (call, callback) => {
    const { id } = call.request;
    try {
      const positionData = await getPositionData(id);
      callback(null, positionData);
    } catch (error) {
      callback(error);
    }
  },
  GetPoolState: async (call, callback) => {
    const { poolAddress, chainId, token0, token1, fee, tickLower, tickUpper, positionLiquidity } = call.request;
    try {
      const poolState = await getPoolState(poolAddress, chainId, token0, token1, fee, tickLower, tickUpper, positionLiquidity);
      callback(null, poolState);
    } catch (error) {
      callback(error);
    }
  },
});

module.exports = server;
