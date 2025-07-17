const sequelize = require('./config/database');
const User = require('./models/user');

async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Veritabanı bağlantısı başarılı!');
    // Modeli senkronize etmeden tabloya dokunma!
    const users = await User.findAll({ limit: 1 });
    console.log('User tablosu erişilebilir:', users);
  } catch (error) {
    console.error('Bağlantı Hatası:', error);
  } finally {
    await sequelize.close();
  }
}

testConnection(); 