const express = require('express');
const CartItem = require('../models/cart_item');
const Product = require('../models/product');
const auth = require('../middleware/auth');
const router = express.Router();

// Sepete ürün ekle
router.post('/', auth, async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    if (!productId || !quantity) {
      return res.status(400).json({ message: 'Ürün ve adet zorunludur.' });
    }
    // Aynı üründen zaten varsa, adedi artır
    let cartItem = await CartItem.findOne({ where: { userId: req.user.id, productId } });
    if (cartItem) {
      cartItem.quantity += quantity;
      await cartItem.save();
    } else {
      cartItem = await CartItem.create({ userId: req.user.id, productId, quantity });
    }
    res.status(201).json({ message: 'Ürün sepete eklendi!', cartItem });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Sepeti görüntüle
router.get('/', auth, async (req, res) => {
  try {
    const cartItems = await CartItem.findAll({
      where: { userId: req.user.id },
      include: [{ model: Product }],
    });
    res.json(cartItems);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Sepetten ürün çıkar
router.delete('/:cartItemId', auth, async (req, res) => {
  try {
    const { cartItemId } = req.params;
    const cartItem = await CartItem.findOne({ where: { id: cartItemId, userId: req.user.id } });
    if (!cartItem) {
      return res.status(404).json({ message: 'Sepet ürünü bulunamadı.' });
    }
    await cartItem.destroy();
    res.json({ message: 'Ürün sepetten çıkarıldı.' });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

module.exports = router; 