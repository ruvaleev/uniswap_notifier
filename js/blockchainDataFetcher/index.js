const grpc = require('@grpc/grpc-js');
const server = require('./server');

const port = process.env.PORT || '50051';
const host = `0.0.0.0:${port}`;

server.bindAsync(
  host,
  grpc.ServerCredentials.createInsecure(),
  (err) => {
    if (err) {
      console.error(`Server error: ${err.message}`);
      throw new Error(`Server error: ${err.message}`);
    } else {
      console.log(`Server listening on ${host}`);
      server.start();
    }
  },
);
