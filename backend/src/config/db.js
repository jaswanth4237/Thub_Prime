const mongoose = require('mongoose');

const getConnection = async () => {
    try{
      await mongoose.connect("mongodb+srv://24p35a4237_db_user:ThubPrime@thubprime.jew9i5b.mongodb.net/ThubPrime");
      console.log("Connected to MongoDB");
    }
    catch(err){
        console.error("Error connecting to MongoDB:", err);
    }
}

module.exports = getConnection;