const { Kafka } = require('kafkajs');

const kafkaBrokers = (process.env.KAFKA_BROKERS || 'localhost:9092').split(',');
const clientId = process.env.KAFKA_CLIENT_ID || 'thub-prime-producer';

const kafka = new Kafka({ clientId, brokers: kafkaBrokers });

const producer = kafka.producer();
let producerReady = false;
let producerUnavailable = false;

const connectProducer = async () => {
  if (producerReady) {
    return true;
  }

  if (producerUnavailable) {
    return false;
  }

  try {
    await producer.connect();
    producerReady = true;
    console.log('Kafka producer connected');
    return true;
  } catch (err) {
    producerUnavailable = true;
    console.warn('Kafka producer unavailable, using local fallback');
    return false;
  }
};

const sendMessage = async (topic, messages) => {
  if (!producerReady) {
    throw new Error('Kafka producer is not connected');
  }

  try {
    // messages: array of { key, value }
    await producer.send({ topic, messages });
  } catch (err) {
    producerReady = false;
    producerUnavailable = true;
    console.warn('Kafka send failed, using local fallback');
    throw err;
  }
};

module.exports = { producer, connectProducer, sendMessage };
