const request = require('supertest');
const app = require('../app');
const sequelize = require('../config/database');
const User = require('../models/user');

describe('Auth API', () => {
  beforeAll(async () => {
    await sequelize.sync({ force: true }); // Test için veritabanını sıfırla
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should register a new user', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ email: 'testuser@example.com', password: '123456' });
    expect(res.statusCode).toBe(201);
    expect(res.body.user).toHaveProperty('id');
    expect(res.body.user.email).toBe('testuser@example.com');
  });

  it('should login with correct credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'testuser@example.com', password: '123456' });
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });
}); 