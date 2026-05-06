const feedItems = require('../controller/feedbackController');        
const express = require('express'); 

const router = express.Router();

router.post('/add',feedItems.postFeedback);

module.exports = router;