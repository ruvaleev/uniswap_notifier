const { ethers } = require('ethers');
const { Token } = require('@uniswap/sdk-core');
const { Pool, Position } = require('@uniswap/v3-sdk');
require('dotenv').config();

const poolAbi = require('./poolAbi.json')
const factoryAbi = require('./factoryAbi.json')

const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);

async function getPoolState(chainId, token0, token1, fee, tickLower, tickUpper, positionLiquidity) {
  const pool = await getPool(chainId, token0, token1, fee)
  const position = new Position({ pool, tickLower: tickLower, tickUpper: tickUpper, liquidity: positionLiquidity })

  return {
    token0: {
      ...token0,
      amount: position.amount0.toFixed(),
      price: pool.token0Price.toSignificant(),
    },
    token1: {
      ...token1,
      amount: position.amount1.toFixed(),
      price: pool.token1Price.toSignificant(),
    }
  }
}

async function getPool(chainId, token0, token1, fee) {
  const poolContract = await getPoolContract(token0.address, token1.address, fee)
  const [liquidity, slot] = await Promise.all([poolContract.liquidity(), poolContract.slot0()]);
  const state = {
    liquidity: liquidity,
    sqrtPriceX96: slot.sqrtPriceX96,
    tick: slot.tick
  }

  return buildPool(
    buildToken(chainId, token0.address, token0.decimals, token0.symbol, token0.name),
    buildToken(chainId, token1.address, token1.decimals, token1.symbol, token1.name),
    fee,
    state
  )
}

async function getPoolContract(token0Address, token1Address, fee) {
  const factoryAddress = '0x1F98431c8aD98523631AE4a59f267346ea31F984';
  const factory = new ethers.Contract(factoryAddress, factoryAbi, provider);
  const poolAddress = await factory.getPool(token0Address, token1Address, fee);
  return new ethers.Contract(poolAddress, poolAbi, provider);
};

function buildPool(token0, token1, fee, state) {
  return new Pool(
    token0,
    token1,
    fee,
    state.sqrtPriceX96.toString(),
    state.liquidity.toString(),
    Number(state.tick)
  );
}

function buildToken(chainId, tokenAddress, decimals, symbol, name) {
  return new Token(chainId, tokenAddress, decimals, symbol, name);
}

module.exports = {
  getPoolState,
};
