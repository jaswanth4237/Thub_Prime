const express = require('express');

const classController = require('../controller/classController');

const router = express.Router();

router.post('/add', classController.postClass);

module.exports = router;