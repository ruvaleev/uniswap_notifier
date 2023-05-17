const { ethers } = require('ethers');
require('dotenv').config();

const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);
const positionManagerAddress = '0xC36442b4a4522E871399CD717aBDD847Ab11FE88';
const positionManagerAbi = require('./positionManagerAbi.json')

async function getPositionData(tokenId) {
  const positionManager = new ethers.Contract(positionManagerAddress, positionManagerAbi, provider);
  const positionData = await positionManager.positions(tokenId);

  return {
    token0: positionData.token0,
    token1: positionData.token1,
    fee: Number(positionData.fee),
    liquidity: positionData.liquidity.toString(),
    tickLower: Number(positionData.tickLower),
    tickUpper: Number(positionData.tickUpper)
  };
}

module.exports = {
  getPositionData,
};
