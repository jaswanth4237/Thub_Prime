const model = require('../models/attendanceModels');

const postAttendance = async (req, res) => {
    try {
        const { classId, studentId, status } = req.body;
        const attendance = new model({
            classId,
            studentId,
            status
        });
        await attendance.save();
        res.status(201).json({
            success: true,
            message: "Attendance Added Successfully",
            data: attendance
        });
    }
    catch (err) {
        console.log(err);
        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

const getAttendanceSummary = async (req, res) => {
    try {
        const { studentId } = req.params;
        const totalSessions = await model.countDocuments({ studentId });
        const presentSessions = await model.countDocuments({ studentId, status: 'present' });
        const percentage = totalSessions > 0 ? (presentSessions / totalSessions * 100).toFixed(1) : 0;

        res.status(200).json({
            success: true,
            totalSessions,
            presentSessions,
            percentage
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

module.exports = { postAttendance, getAttendanceSummary };