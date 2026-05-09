const express = require('express');
const { analyzeEncryptedFeedback } = require('../controller/aiController');

const router = express.Router();

router.post('/process-encrypted-feedback', analyzeEncryptedFeedback);

module.exports = router;
