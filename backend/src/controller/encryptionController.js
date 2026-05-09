const Message = require('../models/Message');

const { encrypt, decrypt } = require('../crypto');

const saveMessage = async (req, res) => {

    try {

        const { message } = req.body;

        if (!message) {
            return res.status(400).json({
                success: false,
                message: 'Message is requireddd'
            });
        }

        // Encrypt message
        const encrypted = encrypt(message);


        const newMessage = new Message(encrypted);

        await newMessage.save();

        res.status(201).json({
            success: true,
            message: 'Encrypted and stored successfully',
            data: newMessage
        });

    }
    catch (error) {

        console.log(error);

        res.status(500).json({
            success: false,
            message: 'Internal Server Error'
        });
    }
}


const getMessage = async (req, res) => {

    try {

        const data = await Message.findById(req.params.id);

        if (!data) {
            return res.status(404).json({
                success: false,
                message: 'Message not found'
            });
        }

        // Decrypt message
        const decrypted = decrypt(
            data.encryptedData,
            data.iv,
            data.authTag
        );

        res.status(200).json({
            success: true,
            decryptedMessage: decrypted
        });

    }
    catch (error) {

        console.log(error);

        res.status(500).json({
            success: false,
            message: 'Internal Server Error'
        });
    }
}


module.exports = {
    saveMessage,
    getMessage
};