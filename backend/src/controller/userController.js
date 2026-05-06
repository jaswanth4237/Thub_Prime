const model = require('../models/userModels');

const createUser = async (req, res) => {

    try {

        const { userId, role } = req.body;

        const existingUser = await model.findOne({ userId });

        if(existingUser) {
            return res.status(400).json({
                success: false,
                message: "User already exists"
            });
        }

        const user = new model({
            userId,
            role
        });

        await user.save();

        res.status(201).json({
            success: true,
            message: "User Created Successfully",
            data: user
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

module.exports = { createUser };