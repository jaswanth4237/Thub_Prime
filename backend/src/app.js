const express = require('express');
const cors = require('cors');
const feedbackRouts = require('./routes/feedbackRouters');
const attendanceRouts = require('./routes/attendanceRouters');

//dabase connection
const getConnection  = require('./config/db');
const app = express();

//Enable CORS for all routes
app.use(cors());

//Middleware to parse JSON bodies
app.use(express.json());

app.get('/', (req,res)=>{
    res.send('Backend is running !');
})

app.use('/feedback', feedbackRouts);
app.use('/attendance', attendanceRouts);
app.get('/hi', (req,res)=>{
    res.send('Backend is running  hi!');
})

//Start the server
app.listen(7100, "0.0.0.0",()=>{
    console.log('Server is running on port 7100');
    console.log('http://localhost:7100');
    getConnection();
} ) 