const model = require('../models/feedbackModels');

const postFeedback = async (req, res) => {
    try{
     const { classId, studentId, mentorId, rating, comments } = req.body;

     const feedback = new model({
        classId : classId,
        studentId : studentId,
        mentorId : mentorId,
        rating : rating,
        comments : comments
     });

     await feedback.save();
     res.status(201).json({ message: "Feedback posted successfully" },feedback);
    }
    catch(err){
        console.error("Error posting feedback:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }   
}

module.exports = 
{postFeedback};