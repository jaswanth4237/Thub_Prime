const express = require('express');
const attendanceController = require('../controller/attendanceController');

const router = express.Router();

router.post('/add', attendanceController.postAttendance);
router.get('/summary/:studentId', attendanceController.getAttendanceSummary);

module.exports = router;