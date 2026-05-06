const mongoose = require('mongoose');

//Attendance Schema
const AttendanceSchema = new mongoose.Schema({
    classId:{
        type:String,
        required:true
    },
    studentId:{
        type:String,
        required:true
    },
    status:{
        required:true,
        type:String,
    },
},
    {
        timestamps:true
    }

);

module.exports = mongoose.model("AttendanceSchema",AttendanceSchema);