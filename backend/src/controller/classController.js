const model = require('../models/classModels');

const postClass = async (req, res) => {

    try {

        const { classId, className, mentorId, schedule } = req.body;

        const classData = new model({
            classId,
            className,
            mentorId,
            schedule
        });

        await classData.save();

        res.status(201).json({
            success: true,
            message: "Class Created Successfully",
            data: classData
        });

    }
    catch(err) {

        console.log(err);

        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

module.exports = { postClass };