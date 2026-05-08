const { Kafka } = require('kafkajs');

const kafkaBrokers = (process.env.KAFKA_BROKERS || 'localhost:9092').split(',');
const clientId = process.env.KAFKA_CLIENT_ID || 'thub-prime-producer';

const kafka = new Kafka({ clientId, brokers: kafkaBrokers });

const producer = kafka.producer();

const connectProducer = async () => {
  try {
    await producer.connect();
    console.log('Kafka producer connected');
  } catch (err) {
    console.error('Kafka producer connection error:', err);
    throw err;
  }
};

const sendMessage = async (topic, messages) => {
  try {
    // messages: array of { key, value }
    await producer.send({ topic, messages });
  } catch (err) {
    console.error('Error sending Kafka message:', err);
    throw err;
  }
};

module.exports = { producer, connectProducer, sendMessage };
