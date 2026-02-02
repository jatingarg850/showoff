/**
 * Fix script to remove unique constraint on CompetitionSettings type field
 * Run: node server/scripts/fix-competition-index.js
 */

const mongoose = require('mongoose');
const path = require('path');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const fixIndex = async () => {
  try {
    console.log('📝 MongoDB URI:', process.env.MONGODB_URI ? '✅ Found' : '❌ Not found');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get the collection
    const db = mongoose.connection.db;
    const collection = db.collection('competitionsettings');

    // List current indexes
    console.log('\n📋 Current indexes:');
    const indexes = await collection.listIndexes().toArray();
    console.log(JSON.stringify(indexes, null, 2));

    // Drop the unique index on type if it exists
    try {
      await collection.dropIndex('type_1');
      console.log('\n✅ Dropped unique index on type field');
    } catch (error) {
      if (error.message.includes('index not found')) {
        console.log('\n⚠️  Index type_1 not found (already removed)');
      } else {
        throw error;
      }
    }

    // List indexes after fix
    console.log('\n📋 Indexes after fix:');
    const newIndexes = await collection.listIndexes().toArray();
    console.log(JSON.stringify(newIndexes, null, 2));

    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    console.log('✅ Index fix completed successfully!');
  } catch (error) {
    console.error('❌ Error fixing index:', error.message);
    process.exit(1);
  }
};

fixIndex();
