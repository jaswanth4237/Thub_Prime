const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');

// Mock models before importing controller
jest.mock('../src/models/attendanceModels');
jest.mock('../src/models/feedbackModels');

const Attendance = require('../src/models/attendanceModels');
const Feedback = require('../src/models/feedbackModels');
const { checkBlockedStatus } = require('../src/controller/blockedController');

const app = express();
app.use(express.json());
app.get('/blocked/status/:studentId', checkBlockedStatus);

describe('Blocked Status Controller', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('should return isBlocked: true if a prior feedback is missing', async () => {
        // Mock attendance in the past
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        Attendance.find.mockResolvedValue([
            { classId: 'C101', studentId: 'S001', status: 'present', createdAt: yesterday }
        ]);

        // Mock NO feedback found
        Feedback.findOne.mockResolvedValue(null);

        const response = await request(app).get('/blocked/status/S001');

        expect(response.status).toBe(200);
        expect(response.body.isBlocked).toBe(true);
        expect(response.body.classId).toBe('C101');
    });

    test('should return isBlocked: false if all prior feedbacks are present', async () => {
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        Attendance.find.mockResolvedValue([
            { classId: 'C101', studentId: 'S001', status: 'present', createdAt: yesterday }
        ]);

        // Mock feedback FOUND
        Feedback.findOne.mockResolvedValue({ studentId: 'S001', classId: 'C101' });

        const response = await request(app).get('/blocked/status/S001');

        expect(response.status).toBe(200);
        expect(response.body.isBlocked).toBe(false);
    });

    test('should return isBlocked: false if attendance is for today only', async () => {
        const today = new Date();
        today.setHours(10, 0, 0, 0);

        Attendance.find.mockResolvedValue([
            { classId: 'C102', studentId: 'S001', status: 'present', createdAt: today }
        ]);

        const response = await request(app).get('/blocked/status/S001');

        expect(response.status).toBe(200);
        expect(response.body.isBlocked).toBe(false);
    });
});
