const express = require('express');
const Favorite = require('../models/favorite');
const Product = require('../models/product');
const auth = require('../middleware/auth');
const router = express.Router();

// Favorilere ürün ekle
router.post('/', auth, async (req, res) => {
  try {
    const { productId } = req.body;
    if (!productId) {
      return res.status(400).json({ message: 'Ürün zorunludur.' });
    }
    // Aynı ürün zaten favorideyse tekrar ekleme
    const existing = await Favorite.findOne({ where: { userId: req.user.id, productId } });
    if (existing) {
      return res.status(409).json({ message: 'Bu ürün zaten favorilerde.' });
    }
    const favorite = await Favorite.create({ userId: req.user.id, productId });
    res.status(201).json({ message: 'Ürün favorilere eklendi!', favorite });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Favorileri listele
router.get('/', auth, async (req, res) => {
  try {
    const favorites = await Favorite.findAll({
      where: { userId: req.user.id },
      include: [{ model: Product }],
    });
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Favorilerden ürün çıkar
router.delete('/:favoriteId', auth, async (req, res) => {
  try {
    const { favoriteId } = req.params;
    const favorite = await Favorite.findOne({ where: { id: favoriteId, userId: req.user.id } });
    if (!favorite) {
      return res.status(404).json({ message: 'Favori bulunamadı.' });
    }
    await favorite.destroy();
    res.json({ message: 'Ürün favorilerden çıkarıldı.' });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

module.exports = router; 