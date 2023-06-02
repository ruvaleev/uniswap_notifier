require('dotenv').config();

const { ethers } = require('ethers');

const getTokenData = async (contractAddress) => {
  const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);

  const abi = [
    'function name() view returns (string)',
    'function symbol() view returns (string)',
    'function decimals() view returns (uint8)',
  ];

  const contract = new ethers.Contract(contractAddress, abi, provider);

  const name = await contract.name.staticCall();
  const symbol = await contract.symbol.staticCall();
  const decimals = await contract.decimals.staticCall();

  return { name, symbol, decimals: Number(decimals) };
};


module.exports = {
  getTokenData,
};
