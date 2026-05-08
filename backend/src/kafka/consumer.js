require('dotenv').config();
const { Kafka } = require('kafkajs');
const topics = require('./topics');
const encryptUtil = require('../crypto');
const EncryptedFeedback = require('../models/encryptedFeedbackModel');
const getConnection = require('../config/db');

const kafkaBrokers = (process.env.KAFKA_BROKERS || 'localhost:9092').split(',');
const clientId = process.env.KAFKA_CLIENT_ID || 'thub-prime-consumer';

const kafka = new Kafka({ clientId, brokers: kafkaBrokers });
const consumer = kafka.consumer({ groupId: process.env.KAFKA_CONSUMER_GROUP || 'feedback-processors' });

const run = async () => {
  try {
    await getConnection();
    await consumer.connect();
    await consumer.subscribe({ topic: topics.FEEDBACK_SUBMISSIONS, fromBeginning: false });

    console.log('Kafka consumer connected and subscribed to', topics.FEEDBACK_SUBMISSIONS);

    await consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const payload = JSON.parse(message.value.toString());

          // Encrypt all fields
          const encryptedClassId = encryptUtil.encrypt(payload.classId || '');
          const encryptedRating = encryptUtil.encrypt((payload.rating || 0).toString());
          const encryptedComment = encryptUtil.encrypt(payload.comment || '');
          const encryptedStudentId = payload.studentId ? encryptUtil.encrypt(payload.studentId) : null;
          const encryptedFacultyId = payload.facultyId ? encryptUtil.encrypt(payload.facultyId) : null;

          const doc = new EncryptedFeedback({
            encryptedClassId,
            encryptedRating,
            encryptedComment,
            encryptedStudentId,
            encryptedFacultyId,
            createdAt: payload.timestamp ? new Date(payload.timestamp) : new Date()
          });

          await doc.save();
          console.log('Stored fully encrypted feedback');
        } catch (err) {
          console.error('Error processing message:', err);
          // Do not crash consumer on single message failure
        }
      }
    });
  } catch (err) {
    console.error('Kafka consumer error:', err);
    process.exit(1);
  }
};

run().catch(err => {
  console.error('Fatal consumer error:', err);
  process.exit(1);
});
