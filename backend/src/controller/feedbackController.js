const feedbackModel = require('../models/feedbackModels');
const attendanceModel = require('../models/attendanceModels');

const postFeedback = async (req, res) => {

    try {
        const { classId, studentId, mentorId, rating, comments } = req.body;

        // Check attendance
        const attendance = await attendanceModel.findOne({
            classId,
            studentId,
            status: 'present'
        });

        if(!attendance) {
            return res.status(400).json({
                success: false,
                message: "Student did not attend class"
            });
        }

        // Prevent duplicate feedback
        const existingFeedback = await feedbackModel.findOne({
            classId,
            studentId
        });

        if(existingFeedback) {
            return res.status(400).json({
                success: false,
                message: "Feedback already submitted"
            });
        }

        const feedback = new feedbackModel({
            classId,
            studentId,
            mentorId,
            rating,
            comments
        });

        await feedback.save();

        res.status(201).json({
            success: true,
            message: "Feedback Submitted Successfully",
            data: feedback
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

module.exports = { postFeedback };