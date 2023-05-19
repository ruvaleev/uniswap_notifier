const { ethers } = require('ethers');
const { Token } = require('@uniswap/sdk-core');
const { Pool, Position } = require('@uniswap/v3-sdk');
require('dotenv').config();

const poolAbi = require('./poolAbi.json')

const provider = new ethers.JsonRpcProvider(process.env.INFURA_PROVIDER_URL);

async function getPoolState(poolAddress, chainId, token0, token1, fee, tickLower, tickUpper, positionLiquidity) {
  const pool = await getPool(poolAddress, chainId, token0, token1, fee)
  const position = new Position({ pool, tickLower: tickLower, tickUpper: tickUpper, liquidity: positionLiquidity })
  const { price0: token0MinPrice, price1: token1MinPrice } = priceFromTick(tickLower, token0.decimals, token1.decimals)
  const { price0: token0MaxPrice, price1: token1MaxPrice } = priceFromTick(tickUpper, token0.decimals, token1.decimals)

  return {
    token0: {
      ...token0,
      amount: position.amount0.toFixed(),
      price: pool.token0Price.toSignificant(),
      minPrice: token0MinPrice.toString(),
      maxPrice: token0MaxPrice.toString()
    },
    token1: {
      ...token1,
      amount: position.amount1.toFixed(),
      price: pool.token1Price.toSignificant(),
      minPrice: token1MinPrice.toString(),
      maxPrice: token1MaxPrice.toString()
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

function priceFromTick(tick, decimals0, decimals1) {
  const price0 = (1.0001 ** tick) / (10 ** (decimals1 - decimals0))
  const price1 = 1 / price0

  return { price0, price1 }
}

module.exports = {
  getPoolState,
};
