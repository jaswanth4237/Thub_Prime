const express = require('express');

const blockedController = require('../controller/blockedController');

const router = express.Router();

router.post('/block', blockedController.blockStudent);

module.exports = router;