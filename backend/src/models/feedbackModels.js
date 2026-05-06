const mongoose = require('mongoose');

//Feedback Schema
const FeedbackSchema = new mongoose.Schema({
    classId:{
        type:String,
        required:true
    },
    studentId:{
        type:String,
        required:true
    },
    mentorId:{
        required:true,
        type:String,
    },
    rating:{
        required:true,
        type:Number, 
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

module.exports = mongoose.model("FeedbackSchema",FeedbackSchema);