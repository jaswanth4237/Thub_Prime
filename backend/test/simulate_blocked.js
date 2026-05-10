require('dotenv').config();
const mongoose = require('mongoose');
const Attendance = require('../src/models/attendanceModels');
const Feedback = require('../src/models/feedbackModels');
const getConnection = require('../src/config/db');

const simulateBlocked = async () => {
    try {
        await getConnection();

        const studentId = 'student-001';
        const classId = 'TEST-CLASS-101';

        console.log('--- Setting up Blocked Scenario ---');

        // 1. Create a "Yesterday" attendance record
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        await Attendance.deleteMany({ studentId, classId });
        await Feedback.deleteMany({ studentId, classId });

        const att = new Attendance({
            studentId,
            classId,
            status: 'present',
            createdAt: yesterday
        });
        await att.save();
        console.log('✅ Created "Yesterday" attendance record for', studentId);

        console.log('✅ Feedback is NOT present for this class.');
        console.log('\nResult: Student should now be BLOCKED when accessing the app.');
        console.log('Run the frontend and it should redirect to BlockScreen.');

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

simulateBlocked();
