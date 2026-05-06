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
    catch(err) {

        console.log(err);

        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

module.exports = { postAttendance };