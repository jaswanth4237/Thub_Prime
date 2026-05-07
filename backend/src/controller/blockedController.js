const blockedModel = require('../models/blockedAccessModels');
const userModel = require('../models/userModels');
const attendanceModel = require('../models/attendanceModels');
const feedbackModel = require('../models/feedbackModels');

const blockStudent = async (req, res) => {

    try {

        const { studentId, classId } = req.body;

        const startOfToday = new Date();
        startOfToday.setHours(0, 0, 0, 0);

        const todayAttendance = await attendanceModel.findOne({
            studentId,
            classId,
            status: 'present',
            createdAt: { $gte: startOfToday }
        });

        if(!todayAttendance) {
            return res.status(400).json({
                success: false,
                message: "Student must be present today before blocking access"
            });
        }

        const priorAttendance = await attendanceModel.findOne({
            studentId,
            classId,
            status: 'present',
            createdAt: { $lt: startOfToday }
        });

        if(!priorAttendance) {
            return res.status(400).json({
                success: false,
                message: "No previous-day attendance found for feedback-based blocking"
            });
        }

        const existingFeedback = await feedbackModel.findOne({
            studentId,
            classId
        });

        if(existingFeedback) {
            return res.status(400).json({
                success: false,
                message: "Feedback already submitted for this class"
            });
        }

        // Create blocked record
        const blocked = new blockedModel({
            studentId,
            classId
        });

        await blocked.save();

        // Update user blocked status
        await userModel.updateOne(
            { userId: studentId },
            { isBlocked: true }
        );

        res.status(201).json({
            success: true,
            message: "Student Blocked Successfully",
            data: blocked
        });

    }
    catch(err) {

        console.log(err);

        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

module.exports = { blockStudent };