const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({

    classId: {
        type: String,
        required: true
    },

    studentId: {
        type: String,
        required: true
    },

    status: {
        type: String,
        enum: ['present', 'absent'],
        required: true
    }

},
{
    timestamps: true
});

module.exports = mongoose.model('attendance', attendanceSchema);