const { createClient } = require('redis');

const redisClient = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

redisClient.on('error', (err) => console.error('Redis Client Error', err));

async function connectRedis() {
  if (!redisClient.isOpen) {
    await redisClient.connect();
  }
}

async function getCache(key) {
  await connectRedis();
  const data = await redisClient.get(key);
  return data ? JSON.parse(data) : null;
}

async function setCache(key, value, ttlSeconds = 60) {
  await connectRedis();
  await redisClient.set(key, JSON.stringify(value), { EX: ttlSeconds });
}

module.exports = {
  getCache,
  setCache,
  connectRedis,
}; 