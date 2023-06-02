const grpc = require('@grpc/grpc-js');

jest.mock('@grpc/grpc-js');
jest.mock('../server', () => ({
  bindAsync: jest.fn()
}));

const server = require('../server');

describe('index.js', () => {
  beforeAll(() => {
    require('../index');
  });

  it('server.bindAsync is called with the correct parameters', () => {
    expect(server.bindAsync).toHaveBeenCalledWith(
      '0.0.0.0:50051',
      grpc.ServerCredentials.createInsecure(),
      expect.any(Function)
    );
  });
});
