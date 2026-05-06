const mongoose = new require('mongoose');

//Class Schema
const ClassSchema = new mongoose.Schema({
    class:{
        type:String,
        required:true,
        unique:true
    },
    mentorId:{
        type:String,
        required:true   
    },
    moduleName:{
        type:String,
        required:true
    },
    technology:{
        type:String,
        required:true
    },
    startDate:{
        type:Date,
        required:true  
},
    endDate:{
        type:Date,
        required:true
    },
    status:{
        type:String,
        required:true
    },
},
    {
        timestamps:true
    },

);

module.exports = mongoose.model("ClassSchema",ClassSchema);