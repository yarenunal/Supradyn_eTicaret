const amqp = require('amqplib');

let channel = null;
let connection = null;
const QUEUE_NAME = 'notifications';

async function connectRabbitMQ() {
  if (channel) return channel;
  const url = process.env.RABBITMQ_URL || 'amqp://localhost';
  connection = await amqp.connect(url);
  channel = await connection.createChannel();
  await channel.assertQueue(QUEUE_NAME, { durable: false });
  return channel;
}

async function sendNotification(message) {
  const ch = await connectRabbitMQ();
  ch.sendToQueue(QUEUE_NAME, Buffer.from(JSON.stringify(message)));
}

module.exports = {
  sendNotification,
  connectRabbitMQ,
  QUEUE_NAME,
}; 