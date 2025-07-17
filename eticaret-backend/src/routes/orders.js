const express = require('express');
const auth = require('../middleware/auth');
const CartItem = require('../models/cart_item');
const Product = require('../models/product');
const Order = require('../models/order');
const OrderItem = require('../models/order_item');
const Payment = require('../models/payment');
const { sendNotification } = require('../utils/rabbitmq');
const router = express.Router();

// Sipariş oluştur (ödeme simülasyonu ile)
router.post('/', auth, async (req, res) => {
  try {
    // Kullanıcının sepetini al
    const cartItems = await CartItem.findAll({ where: { userId: req.user.id }, include: [Product] });
    if (!cartItems.length) {
      return res.status(400).json({ message: 'Sepetiniz boş.' });
    }
    // Toplam tutarı hesapla
    let total = 0;
    cartItems.forEach(item => {
      total += parseFloat(item.Product.price) * item.quantity;
    });
    // Siparişi oluştur
    const order = await Order.create({ userId: req.user.id, total, status: 'paid' });
    // Sipariş ürünlerini oluştur
    for (const item of cartItems) {
      await OrderItem.create({
        orderId: order.id,
        productId: item.productId,
        quantity: item.quantity,
        price: item.Product.price,
      });
    }
    // Ödeme kaydını oluştur (simülasyon)
    await Payment.create({
      orderId: order.id,
      amount: total,
      status: 'paid',
      paymentMethod: req.body.paymentMethod || 'credit_card',
    });
    // Sepeti temizle
    await CartItem.destroy({ where: { userId: req.user.id } });
    // Bildirim gönder (RabbitMQ)
    await sendNotification({
      type: 'order_created',
      userId: req.user.id,
      orderId: order.id,
      total,
      message: `Siparişiniz başarıyla oluşturuldu! Sipariş No: ${order.id}`
    });
    res.status(201).json({ message: 'Sipariş ve ödeme başarıyla oluşturuldu!', orderId: order.id });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

// Sipariş geçmişi
router.get('/', auth, async (req, res) => {
  try {
    const orders = await Order.findAll({
      where: { userId: req.user.id },
      include: [{
        model: OrderItem,
        include: [Product],
      }, Payment],
      order: [['createdAt', 'DESC']],
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message || error });
  }
});

module.exports = router; 