const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({

    classId: {
        type: String,
        required: true
    },

    studentId: {
        type: String,
        required: true
    },

    mentorId: {
        type: String,
        required: true
    },

    rating: {
        type: Number,
        min: 1,
        max: 5,
        required: true
    },

    comments: {
        type: String
    }

},
{
    timestamps: true
});

module.exports = mongoose.model('feedbacks', feedbackSchema);