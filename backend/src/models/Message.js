const mongoose = require("mongoose");

const MessageSchema = new mongoose.Schema({
  encryptedData: String,
  iv: String,
  authTag: String
});

module.exports = mongoose.model("Message", MessageSchema);