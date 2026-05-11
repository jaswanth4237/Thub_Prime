const express = require('express');
const { analyzeEncryptedFeedback } = require('../controller/aiController');
const { authorize } = require('../middleware/authMiddleware');

const router = express.Router();

// Only mentors and admins can trigger AI analysis of feedback
router.post('/process-encrypted-feedback', authorize(['mentor', 'admin']), analyzeEncryptedFeedback);

module.exports = router;
