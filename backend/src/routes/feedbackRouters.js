const express = require('express');

const feedbackController = require('../controller/feedbackController');

const router = express.Router();

router.post('/add', feedbackController.postFeedback);

module.exports = router;