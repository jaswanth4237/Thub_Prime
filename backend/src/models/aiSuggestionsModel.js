const mongoose = require('mongoose');

const aiSuggestionSchema = new mongoose.Schema({
  classId: { type: String, required: true },
  mentorId: { type: String },
  feedbackCount: { type: Number },
  overallRating: { type: String },
  analysis: { type: mongoose.Schema.Types.Mixed },
  rawResponse: { type: String },
  prompt: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ai_suggestions', aiSuggestionSchema);
