const express = require('express');
const router = express.Router();
const User = require('../models/user');

// POST /api/device-token
router.post('/', async (req, res) => {
  const { userId, deviceToken } = req.body;
  if (!userId || !deviceToken) {
    return res.status(400).json({ error: 'userId ve deviceToken gereklidir.' });
  }
  try {
    const [updated] = await User.update(
      { deviceToken },
      { where: { id: userId } }
    );
    if (updated) {
      res.json({ success: true });
    } else {
      res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatası.' });
  }
});

module.exports = router; 