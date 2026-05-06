const model = require('../models/attendanceModels');

const postAttendance = async (req, res) => {
    try{
     const { classId, studentId, status } = req.body;

     const attendance = new model({
        classId : classId,
        studentId : studentId,
        status : status
     });

     await attendance.save();
     res.status(201).json({ message: "Attendance posted successfully" },attendance);
    }
    catch(err){
        console.error("Error posting attendance:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }   
}

module.exports = 
{postAttendance};