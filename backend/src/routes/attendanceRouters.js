const attendanceItems = require('../controller/attendanceController');
const express = require('express');

const router = express.Router();

router.post('/add', attendanceItems.postAttendance);

module.exports = router;