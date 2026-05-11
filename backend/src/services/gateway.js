require('dotenv').config();

const { startHttpService } = require('./shared/httpService');

const classRoutes = require('../routes/classRouters');
const attendanceRoutes = require('../routes/attendanceRouters');
const feedbackRoutes = require('../routes/feedbackRouters');
const userRoutes = require('../routes/userRouters');
const blockedRoutes = require('../routes/blockedRouters');
const encryptionRoutes = require('../routes/encryptionRouters');
const aiRoutes = require('../routes/aiRouter');

startHttpService({
  name: 'Gateway Service',
  port: process.env.GATEWAY_PORT || process.env.PORT || 7100,
  mountRoutes(app) {
    app.get('/', (req, res) => {
      res.send('Gateway Running');
    });

    app.use('/class', classRoutes);
    app.use('/attendance', attendanceRoutes);
    app.use('/feedback', feedbackRoutes);
    app.use('/user', userRoutes);
    app.use('/blocked', blockedRoutes);
    app.use('/encryption', encryptionRoutes);
    app.use('/ai', aiRoutes);
  }
});