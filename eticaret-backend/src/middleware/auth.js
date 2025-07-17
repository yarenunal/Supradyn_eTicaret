const redisClient = require('../utils/redis');
const jwt = require('jsonwebtoken');

module.exports = async function (req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Token bulunamadı, yetkisiz erişim.' });
  }
  // Blacklist kontrolü
  const isBlacklisted = await redisClient.getCache(`blacklist:${token}`);
  if (isBlacklisted) {
    return res.status(401).json({ message: 'Token geçersiz (blacklist).' });
  }
  jwt.verify(token, process.env.JWT_SECRET || 'gizli_anahtar', (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Geçersiz veya süresi dolmuş token.' });
    }
    req.user = user;
    next();
  });
}; 