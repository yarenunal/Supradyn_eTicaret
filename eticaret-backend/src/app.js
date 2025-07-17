const express = require('express');
const cors = require('cors'); // CORS paketi eklendi
const app = express();

// CORS ayarı (geliştirme için herkese açık)
app.use(cors());
// Eğer sadece belirli origin'lere izin vermek istersen, yukarıdaki app.use(cors()) satırını
// aşağıdaki ile değiştir:
// app.use(cors({
//   origin: ['http://localhost:3000', 'http://localhost:8081', 'http://127.0.0.1:3000', 'http://localhost'],
//   credentials: true
// }));

app.use(express.json());

// Örnek bir route
app.get('/', (req, res) => {
  res.send('E-Ticaret API Çalışıyor!');
});

app.post('/test', (req, res) => {
  console.log('Gelen body:', req.body);
  res.json({ body: req.body });
});

const authRouter = require('./routes/auth');
app.use('/api/auth', authRouter);

const productsRouter = require('./routes/products');
app.use('/api/products', productsRouter);

const cartRouter = require('./routes/cart');
app.use('/api/cart', cartRouter);

const favoritesRouter = require('./routes/favorites');
app.use('/api/favorites', favoritesRouter);

const ordersRouter = require('./routes/orders');
app.use('/api/orders', ordersRouter);

const deviceTokenRouter = require('./routes/deviceToken');
app.use('/api/device-token', deviceTokenRouter);

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

module.exports = app;