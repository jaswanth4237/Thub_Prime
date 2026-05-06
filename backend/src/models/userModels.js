const mongoose = new require('mongoose');

//User Schema
const UserSchema = new mongoose.Schema({
    userId:{
        type:String,
        required:true,
        unique:true
    },
    role:{
        type:String,
        required:true   
    },
    isBlocked:{
        type:Boolean,
        default:false,
        required:true
    },
},
    {
        timestamps:true
    },

);

module.exports = mongoose.model("UserSchema",UserSchema);