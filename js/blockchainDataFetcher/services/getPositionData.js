const { ethers } = require('ethers');
require('dotenv').config();

const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);
const positionManagerAddress = '0xC36442b4a4522E871399CD717aBDD847Ab11FE88';
const positionManagerAbi = require('./positionManagerAbi.json')
const factoryAbi = require('./factoryAbi.json')

async function getPositionData(tokenId) {
  const positionManager = new ethers.Contract(positionManagerAddress, positionManagerAbi, provider);
  const positionData = await positionManager.positions(tokenId);
  const poolAddress = await getPoolAddress(positionData.token0, positionData.token1, positionData.fee)

  return {
    token0: positionData.token0,
    token1: positionData.token1,
    fee: Number(positionData.fee),
    liquidity: positionData.liquidity.toString(),
    tickLower: Number(positionData.tickLower),
    tickUpper: Number(positionData.tickUpper),
    poolAddress: poolAddress
  };
}

async function getPoolAddress(token0Address, token1Address, fee) {
  const factoryAddress = '0x1F98431c8aD98523631AE4a59f267346ea31F984';
  const factory = new ethers.Contract(factoryAddress, factoryAbi, provider);

  return await factory.getPool(token0Address, token1Address, fee);

}

module.exports = {
  getPositionData,
};
