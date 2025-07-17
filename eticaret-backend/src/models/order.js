const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const OrderItem = require('./order_item');
const Payment = require('./payment');

const Order = sequelize.define('Order', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  total: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  status: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'paid', // veya 'pending', 'cancelled' gibi durumlar eklenebilir
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
  
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'orders',
});

Order.hasMany(OrderItem, { foreignKey: 'orderId' });
Order.hasMany(Payment, { foreignKey: 'orderId' });

module.exports = Order; 