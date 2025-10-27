const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function fixIndexes() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const likesCollection = db.collection('likes');

    // Drop all indexes except _id
    console.log('Dropping old indexes...');
    await likesCollection.dropIndexes();
    console.log('✅ Old indexes dropped');

    // The new indexes will be created automatically when the server starts
    console.log('✅ Indexes will be recreated on next server start');
    
    await mongoose.connection.close();
    console.log('Done!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

fixIndexes();
