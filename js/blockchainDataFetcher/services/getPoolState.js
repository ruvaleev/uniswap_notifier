const { ethers } = require('ethers');
const { Token } = require('@uniswap/sdk-core');
const { Pool, Position } = require('@uniswap/v3-sdk');
require('dotenv').config();

const poolAbi = require('./poolAbi.json')

const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);

async function getPoolState(poolAddress, chainId, token0, token1, fee, tickLower, tickUpper, positionLiquidity) {
  const pool = await getPool(poolAddress, chainId, token0, token1, fee)
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

async function getPool(poolAddress, chainId, token0, token1, fee) {
  const poolContract = new ethers.Contract(poolAddress, poolAbi, provider);
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
