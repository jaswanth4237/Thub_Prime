const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({

    userId: {
        type: String,
        required: true,
        unique: true
    },

    role: {
        type: String,
        enum: ['student', 'mentor', 'admin'],
        required: true
    },

    isBlocked: {
        type: Boolean,
        default: false
    }

},
{
    timestamps: true
});

module.exports = mongoose.model('users', userSchema);