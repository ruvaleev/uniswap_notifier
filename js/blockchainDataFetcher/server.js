const protoLoader = require('@grpc/proto-loader');
const grpc = require('@grpc/grpc-js');

const { getTokenData } = require('./services/getTokenData')
const { getPositionData } = require('./services/getPositionData')

const PROTO_PATH = '../../protos/blockchain_data_fetcher.proto';

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
});

module.exports = server;
