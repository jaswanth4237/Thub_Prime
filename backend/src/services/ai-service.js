require('dotenv').config();

const { startHttpService } = require('./shared/httpService');
const aiRoutes = require('../routes/aiRouter');

startHttpService({
  name: 'AI Analysis Service',
  port: process.env.AI_SERVICE_PORT || 7102,
  mountRoutes(app) {
    app.get('/', (req, res) => {
      res.send('AI Analysis Service Running');
    });

    app.use('/ai', aiRoutes);
  }
});