process.env.SECRET_KEY = process.env.SECRET_KEY || 'a'.repeat(32);

const { encrypt, decrypt } = require('../src/crypto');

const testText = 'Hello, encryption test!';

console.log('Using SECRET_KEY length:', Buffer.from(process.env.SECRET_KEY).length);

const enc = encrypt(testText);
console.log('Encrypted object:', enc);

const dec = decrypt(enc.encryptedData, enc.iv, enc.authTag);
console.log('Decrypted text:', dec);

if (dec === testText) {
  console.log('SUCCESS: decrypted text matches original');
  process.exit(0);
} else {
  console.error('FAIL: decrypted text does not match original');
  process.exit(1);
}
