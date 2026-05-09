require('dotenv').config();

const express = require('express');
const cors = require('cors');
const getConnection = require('./config/db');

const classRoutes = require('./routes/classRouters');
const attendanceRoutes = require('./routes/attendanceRouters');
const feedbackRoutes = require('./routes/feedbackRouters');
const userRoutes = require('./routes/userRouters');
const blockedRoutes = require('./routes/blockedRouters');
const encryptionRoutes = require('./routes/encryptionRouters');
const aiRoutes = require('./routes/aiRouter');
const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('Backend Running');
});


app.use('/class', classRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/feedback', feedbackRoutes);
app.use('/user', userRoutes);
app.use('/blocked', blockedRoutes);
app.use('/encryption', encryptionRoutes);
app.use('/ai', aiRoutes);

const PORT = 7100;


const startServer = async () => {
    try {
        await getConnection();
        app.listen(PORT, () => {
            console.log(`Server Running on ${PORT}`);
        });
    }
    catch (error) {
        console.error('Failed to start server because MongoDB is unavailable:', error);
        process.exit(1);
    }
};

startServer();