const mongoose = require('mongoose');

const classSchema = new mongoose.Schema({

    classId: {
        type: String,
        required: true,
        unique: true
    },

    className: {
        type: String,
        required: true
    },

    mentorId: {
        type: String,
        required: true
    },

    schedule: {
        type: String,
        required: true
    }

},
{
    timestamps: true
});

module.exports = mongoose.model('classes', classSchema);