const express = require('express');

const blockedController = require('../controller/blockedController');

const router = express.Router();

router.post('/block', blockedController.blockStudent);
router.get('/status/:studentId', blockedController.checkBlockedStatus);

module.exports = router;