const sequelize = require('./config/database');
const User = require('./models/user');
const Product = require('./models/product');
const CartItem = require('./models/cart_item');
const Favorite = require('./models/favorite');
const Order = require('./models/order');
const OrderItem = require('./models/order_item');
const Payment = require('./models/payment');

async function syncDb() {
  try {
    await sequelize.authenticate();
    console.log('Veritabanı bağlantısı başarılı!');
    await User.sync({ alter: true });
    await Product.sync({ alter: true });
    await CartItem.sync({ alter: true });
    await Favorite.sync({ alter: true });
    await Order.sync({ alter: true });
    await OrderItem.sync({ alter: true });
    await Payment.sync({ alter: true });
    console.log('Tüm tablolar senkronize edildi!');
  } catch (error) {
    console.error('Hata:', error);
  } finally {
    await sequelize.close();
  }
}

syncDb(); 