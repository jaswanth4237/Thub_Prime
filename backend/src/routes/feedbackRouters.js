const feedItems = require('../controller/feedbackController');        
const express = require('express'); 

const router = express.Router();

router.post('/feedback',feedItems.postFeedback);

module.exports = router;