const feedbackModel = require('../models/feedbackModels');
const EncryptedFeedback = require('../models/encryptedFeedbackModel');
const encryptUtil = require('../crypto');
const { sendMessage, connectProducer } = require('../kafka/producer');
const topics = require('../kafka/topics');

const persistFeedbackFallback = async (payload) => {
    try {
        console.log('=== Saving feedback to MongoDB model');
        await new feedbackModel({
            classId: payload.classId,
            studentId: payload.studentId,
            mentorId: payload.facultyId,
            rating: payload.rating,
            comments: payload.comment,
        }).save();
        console.log('=== Feedback saved to MongoDB successfully');
    } catch (err) {
        console.error('=== Failed to save feedback to feedback model:', err.message);
    }

    if (process.env.SECRET_KEY) {
        try {
            console.log('=== Attempting to save encrypted feedback');
            const encryptedFeedback = new EncryptedFeedback({
                encryptedClassId: encryptUtil.encrypt(payload.classId || ''),
                encryptedRating: encryptUtil.encrypt((payload.rating || 0).toString()),
                encryptedComment: encryptUtil.encrypt(payload.comment || ''),
                encryptedStudentId: payload.studentId ? encryptUtil.encrypt(payload.studentId) : null,
                encryptedFacultyId: payload.facultyId ? encryptUtil.encrypt(payload.facultyId) : null,
                createdAt: payload.timestamp ? new Date(payload.timestamp) : new Date(),
            });
            await encryptedFeedback.save();
            console.log('=== Encrypted feedback saved successfully');
        } catch (err) {
            console.error('=== Failed to save encrypted feedback:', err.message);
        }
    } else {
        console.log('=== SECRET_KEY not configured, skipping encrypted feedback storage');
    }
};

const postFeedback = async (req, res) => {
    try {
        console.log('=== postFeedback called');
        console.log('=== Request body:', req.body);
        
        const { classId, studentId, mentorId, rating, comments } = req.body;

        if (!classId || !studentId || !mentorId || rating === undefined) {
            console.warn('=== Missing required fields');
            return res.status(400).json({
                success: false,
                message: "Missing required fields: classId, studentId, mentorId, rating"
            });
        }

        const payload = {
            classId,
            studentId,
            facultyId: mentorId,
            rating,
            comment: comments,
            timestamp: new Date().toISOString()
        };

        try {
            console.log('=== Attempting Kafka connection');
            const kafkaReady = await connectProducer();
            console.log('=== Kafka ready:', kafkaReady);

            if (kafkaReady) {
                console.log('=== Sending message to Kafka');
                await sendMessage(topics.FEEDBACK_SUBMISSIONS, [
                    { key: studentId, value: JSON.stringify(payload) }
                ]);
                console.log('=== Kafka message sent successfully');
            } else {
                console.log('=== Kafka not ready, using fallback');
                await persistFeedbackFallback(payload);
            }
        } catch (err) {
            console.warn('=== Kafka error:', err.message);
            await persistFeedbackFallback(payload);
        }

        console.log('=== Sending 202 success response');
        res.status(202).json({
            success: true,
            message: 'Feedback submitted and will be processed asynchronously'
        });

    } catch(err) {
        console.error('=== Error in postFeedback:', err.message);
        console.error('=== Stack trace:', err.stack);
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
}

module.exports = { postFeedback };