const mongoose = require('mongoose');

const blockedSchema = new mongoose.Schema({

    studentId: {
        type: String,
        required: true
    },

    classId: {
        type: String,
        required: true
    },

    reason: {
        type: String,
        default: 'Feedback Pending'
    },

    isBlocked: {
        type: Boolean,
        default: true
    }

},
{
    timestamps: true
});

module.exports = mongoose.model('blocked_access', blockedSchema);