const mongoose = require('mongoose');

// BlockedAccess Schema
const BlockedAccessSchema = new mongoose.Schema({
    studentId:{
        type:String,
        required:true
    },
    classId:{
        type:String,
        required:true
    },
    reason:{
        required:true,
        type:String,
    },
    isBlocked:{
        required:true,
        type:Boolean, 
    },
    comments:{
        required:true,
        type:String,
    },
},
    {
        timestamps:true
    }

);

module.exports = mongoose.model("BlockedAccessSchema",BlockedAccessSchema);