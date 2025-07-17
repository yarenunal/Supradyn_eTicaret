const express = require('express');
const Product = require('../models/product');
const { getCache, setCache } = require('../utils/redis');
const router = express.Router();

// Ürün ekle (admin veya test amaçlı)
router.post('/', async (req, res) => {
  try {
    const { name, description, price, stock, imageUrl, category } = req.body;
    if (!name || !price) {
      return res.status(400).json({ message: 'Ürün adı ve fiyatı zorunludur.' });
    }
    const product = await Product.create({ name, description, price, stock, imageUrl, category });
    res.status(201).json({ message: 'Ürün başarıyla eklendi!', product });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Ürünleri listele (arama ve filtreleme ile, Redis cache ile)
router.get('/', async (req, res) => {
  try {
    const { search, category, minPrice, maxPrice } = req.query;
    const cacheKey = `products:${search || ''}:${category || ''}:${minPrice || ''}:${maxPrice || ''}`;
    const cached = await getCache(cacheKey);
    if (cached) {
      return res.json(cached);
    }
    const where = {};
    if (search) {
      where.name = { [require('sequelize').Op.iLike]: `%${search}%` };
    }
    if (category) {
      where.category = category;
    }
    if (minPrice) {
      where.price = where.price || {};
      where.price[require('sequelize').Op.gte] = minPrice;
    }
    if (maxPrice) {
      where.price = where.price || {};
      where.price[require('sequelize').Op.lte] = maxPrice;
    }
    const products = await Product.findAll({ where });
    await setCache(cacheKey, products, 60); // 60 saniye cache
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

module.exports = router; 
