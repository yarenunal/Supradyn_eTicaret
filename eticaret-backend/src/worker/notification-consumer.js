const amqp = require('amqplib');
const { QUEUE_NAME } = require('../utils/rabbitmq');

async function startConsumer() {
  const connection = await amqp.connect('amqp://localhost');
  const channel = await connection.createChannel();
  await channel.assertQueue(QUEUE_NAME, { durable: false });
  console.log('Bildirim consumer başlatıldı. Kuyruk dinleniyor...');
  channel.consume(QUEUE_NAME, (msg) => {
    if (msg !== null) {
      const notification = JSON.parse(msg.content.toString());
      console.log('Yeni bildirim:', notification);
      // Burada e-posta, push notification, SMS gibi işlemler yapılabilir
      channel.ack(msg);
    }
  });
}

startConsumer().catch(console.error); 