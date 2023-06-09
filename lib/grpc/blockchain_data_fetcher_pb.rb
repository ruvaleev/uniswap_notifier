# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: blockchain_data_fetcher.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("blockchain_data_fetcher.proto", :syntax => :proto3) do
    add_message "TokenRequest" do
      optional :address, :string, 1
    end
    add_message "TokenResponse" do
      optional :name, :string, 1
      optional :symbol, :string, 2
      optional :decimals, :int32, 3
    end
    add_message "PositionRequest" do
      optional :id, :int32, 1
    end
    add_message "PositionResponse" do
      optional :token0, :string, 1
      optional :token1, :string, 2
      optional :fee, :int32, 3
      optional :tickLower, :int32, 4
      optional :tickUpper, :int32, 5
      optional :liquidity, :string, 6
      optional :poolAddress, :string, 7
    end
    add_message "PoolStateRequest" do
      optional :poolAddress, :string, 1
      optional :chainId, :int32, 2
      optional :token0, :message, 3, "PoolStateRequest.Token"
      optional :token1, :message, 4, "PoolStateRequest.Token"
      optional :fee, :int32, 5
      optional :tickLower, :int32, 6
      optional :tickUpper, :int32, 7
      optional :positionLiquidity, :string, 8
    end
    add_message "PoolStateRequest.Token" do
      optional :address, :string, 1
      optional :decimals, :int32, 2
      optional :symbol, :string, 3
      optional :name, :string, 4
    end
    add_message "PoolStateResponse" do
      optional :token0, :message, 1, "PoolStateResponse.Token"
      optional :token1, :message, 2, "PoolStateResponse.Token"
    end
    add_message "PoolStateResponse.Token" do
      optional :address, :string, 1
      optional :decimals, :int32, 2
      optional :symbol, :string, 3
      optional :name, :string, 4
      optional :amount, :string, 5
      optional :price, :string, 6
      optional :minPrice, :string, 7
      optional :maxPrice, :string, 8
    end
  end
end

TokenRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("TokenRequest").msgclass
TokenResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("TokenResponse").msgclass
PositionRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PositionRequest").msgclass
PositionResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PositionResponse").msgclass
PoolStateRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PoolStateRequest").msgclass
PoolStateRequest::Token = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PoolStateRequest.Token").msgclass
PoolStateResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PoolStateResponse").msgclass
PoolStateResponse::Token = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("PoolStateResponse.Token").msgclass
