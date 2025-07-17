const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const router = express.Router();
const redisClient = require('../utils/redis');
const auth = require('../middleware/auth');

// Kayıt (Register)
router.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email ve şifre zorunludur.' });
    }
    // Kullanıcı var mı kontrol et
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: 'Bu email ile zaten kayıtlı bir kullanıcı var.' });
    }
    // Şifreyi hashle
    const hashedPassword = await bcrypt.hash(password, 10);
    // Kullanıcıyı oluştur
    const user = await User.create({ email, password: hashedPassword });
    res.status(201).json({ message: 'Kayıt başarılı!', user: { id: user.id, email: user.email } });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Giriş (Login)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email ve şifre zorunludur.' });
    }
    // Kullanıcıyı bul
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: 'Geçersiz email veya şifre.' });
    }
    // Şifreyi kontrol et
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Geçersiz email veya şifre.' });
    }
    // JWT token oluştur
    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || 'gizli_anahtar', { expiresIn: '7d' });
    res.json({ message: 'Giriş başarılı!', token });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Çıkış (Logout) - Token'ı blacklist'e ekle
router.post('/logout', auth, async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.status(400).json({ message: 'Token bulunamadı.' });

    // Token süresi kadar Redis'te tut
    const decoded = jwt.decode(token);
    const exp = decoded.exp; // saniye cinsinden
    const now = Math.floor(Date.now() / 1000);
    const ttl = exp - now;
    if (ttl > 0) {
      await redisClient.set(`blacklist:${token}`, '1', { EX: ttl });
    }
    res.json({ message: 'Çıkış başarılı, token blacklist\'e eklendi.' });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

module.exports = router; 
