const blockedModel = require('../models/blockedAccessModels');
const userModel = require('../models/userModels');

const blockStudent = async (req, res) => {

    try {

        const { studentId, classId } = req.body;

        // Create blocked record
        const blocked = new blockedModel({
            studentId,
            classId
        });

        await blocked.save();

        // Update user blocked status
        await userModel.updateOne(
            { userId: studentId },
            { isBlocked: true }
        );

        res.status(201).json({
            success: true,
            message: "Student Blocked Successfully",
            data: blocked
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

module.exports = { blockStudent };