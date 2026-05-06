const model = require('../model/classModels');

const postClass = async (req , res) => {
    try{
     const { classId, className, mentorId, schedule } = req.body;
        const classData = new model({   
            classId : classId,
            className : className,
            mentorId : mentorId,
            schedule : schedule
        }); 
        await classData.save();
        res.status(201).json({ message: "Class posted successfully" },classData);
    }
    catch(err){
        console.error("Error posting class:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }       

}

module.exports = 
{postClass};