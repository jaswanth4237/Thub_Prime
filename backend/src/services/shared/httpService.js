const express = require('express');
const cors = require('cors');
const getConnection = require('../../config/db');

async function startHttpService({ name, port, mountRoutes }) {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get('/', (req, res) => {
    res.json({ service: name, status: 'ok' });
  });

  if (typeof mountRoutes === 'function') {
    mountRoutes(app);
  }

  try {
    await getConnection();
  } catch (error) {
    console.error(`${name} failed to connect to MongoDB:`, error);
    process.exit(1);
  }

  app.listen(port, '0.0.0.0', () => {
    console.log(`${name} running on ${port}`);
  });
}

module.exports = { startHttpService };