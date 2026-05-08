const mongoose = require('mongoose');

const encryptedFieldSchema = new mongoose.Schema({
  encryptedData: String,
  iv: String,
  authTag: String
}, { _id: false });

const schema = new mongoose.Schema({
  encryptedClassId: { type: encryptedFieldSchema, required: true },
  encryptedRating: { type: encryptedFieldSchema, required: true },
  encryptedComment: { type: encryptedFieldSchema, required: true },
  encryptedStudentId: { type: encryptedFieldSchema, required: false },
  encryptedFacultyId: { type: encryptedFieldSchema, required: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('encryptedFeedbacks', schema);
