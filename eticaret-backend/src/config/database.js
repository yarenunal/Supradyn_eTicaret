const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME || 'eticaret',
  process.env.DB_USER || 'postgres',
  process.env.DB_PASSWORD || 'postgres',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'postgres',
    port: process.env.DB_PORT || 5432,
    logging: false,
  }
);

module.exports = sequelize; 