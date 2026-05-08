const crypto = require("crypto");

const algorithm = "aes-256-gcm";

const secretKey = Buffer.from(process.env.SECRET_KEY);

function encrypt(text) {

  // Generate random IV
  const iv = crypto.randomBytes(12);

  const cipher = crypto.createCipheriv(
    algorithm,
    secretKey,
    iv
  );

  let encrypted = cipher.update(text, "utf8", "hex");

  encrypted += cipher.final("hex");

  const authTag = cipher.getAuthTag();

  return {
    encryptedData: encrypted,
    iv: iv.toString("hex"),
    authTag: authTag.toString("hex")
  };
}

function decrypt(encryptedData, iv, authTag) {

  const decipher = crypto.createDecipheriv(
    algorithm,
    secretKey,
    Buffer.from(iv, "hex")
  );

  decipher.setAuthTag(
    Buffer.from(authTag, "hex")
  );

  let decrypted = decipher.update(
    encryptedData,
    "hex",
    "utf8"
  );

  decrypted += decipher.final("utf8");

  return decrypted;
}

module.exports = {
  encrypt,
  decrypt
};