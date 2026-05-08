const feedbackModel = require('../models/feedbackModels');
const attendanceModel = require('../models/attendanceModels');
const { sendMessage, connectProducer } = require('../kafka/producer');
const topics = require('../kafka/topics');

// Send feedback to Kafka for asynchronous processing
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

        // Prevent duplicate feedback (quick check against existing collection)
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

        // Build payload for Kafka
        const payload = {
            classId,
            studentId,
            facultyId: mentorId,
            rating,
            comment: comments,
            timestamp: new Date().toISOString()
        };

        // Ensure producer is connected (connectProducer is idempotent)
        try {
            await connectProducer();
        } catch (err) {
            // If we cannot connect to Kafka, return error
            console.error('Could not connect to Kafka producer:', err);
            return res.status(503).json({ success: false, message: 'Service unavailable' });
        }

        // Send event to Kafka topic
        await sendMessage(topics.FEEDBACK_SUBMISSIONS, [
            { key: studentId, value: JSON.stringify(payload) }
        ]);

        // Return immediate success (async processing will persist the data)
        res.status(202).json({
            success: true,
            message: 'Feedback submitted and will be processed asynchronously'
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