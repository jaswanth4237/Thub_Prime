const express = require('express');

const {
    saveMessage,
    getMessage
} = require('../controller/encryptionController');

const router = express.Router();

// Save encrypted message
router.post('/save', saveMessage);

// Get decrypted message
router.get('/message/:id', getMessage);

module.exports = router;