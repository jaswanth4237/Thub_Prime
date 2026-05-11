require('dotenv').config();

const { startHttpService } = require('./shared/httpService');
const feedbackRoutes = require('../routes/feedbackRouters');

startHttpService({
  name: 'Feedback Service',
  port: process.env.FEEDBACK_SERVICE_PORT || 7101,
  mountRoutes(app) {
    app.get('/', (req, res) => {
      res.send('Feedback Service Running');
    });

    app.use('/feedback', feedbackRoutes);
  }
});