const feedbackModel = require('../models/feedbackModels');
const EncryptedFeedback = require('../models/encryptedFeedbackModel');
const encryptUtil = require('../crypto');
const { sendMessage, connectProducer } = require('../kafka/producer');
const topics = require('../kafka/topics');

const persistFeedbackFallback = async (payload) => {
    await new feedbackModel({
        classId: payload.classId,
        studentId: payload.studentId,
        mentorId: payload.facultyId,
        rating: payload.rating,
        comments: payload.comment,
    }).save();

    const encryptedFeedback = new EncryptedFeedback({
        encryptedClassId: encryptUtil.encrypt(payload.classId || ''),
        encryptedRating: encryptUtil.encrypt((payload.rating || 0).toString()),
        encryptedComment: encryptUtil.encrypt(payload.comment || ''),
        encryptedStudentId: payload.studentId ? encryptUtil.encrypt(payload.studentId) : null,
        encryptedFacultyId: payload.facultyId ? encryptUtil.encrypt(payload.facultyId) : null,
        createdAt: payload.timestamp ? new Date(payload.timestamp) : new Date(),
    });

    await encryptedFeedback.save();
};

// Send feedback to Kafka for asynchronous processing
const postFeedback = async (req, res) => {
    try {
        const { classId, studentId, mentorId, rating, comments } = req.body;

        // Build payload for Kafka
        const payload = {
            classId,
            studentId,
            facultyId: mentorId,
            rating,
            comment: comments,
            timestamp: new Date().toISOString()
        };

        // Try Kafka first; if it is unavailable, store the feedback directly so the flow still works.
        try {
            const kafkaReady = await connectProducer();

            if (kafkaReady) {
                await sendMessage(topics.FEEDBACK_SUBMISSIONS, [
                    { key: studentId, value: JSON.stringify(payload) }
                ]);
            } else {
                await persistFeedbackFallback(payload);
            }
        } catch (err) {
            console.warn('Kafka unavailable, saving feedback locally');
            await persistFeedbackFallback(payload);
        }

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