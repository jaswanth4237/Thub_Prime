const express = require('express');
const cors = require('cors');

const app = express();

//Enable CORS for all routes
app.use(cors());

//Middleware to parse JSON bodies
app.use(express.json());

app.get('/', (req,res)=>{
    res.send('Hello World !');
})

//Start the server
app.listen(7100, "0.0.0.0",()=>{
    console.log('Server is running on port 7100');
    console.log('http://localhost:7100');
    // getConnection();
    console.log('Connected to MongoDB');
} )