/**
 * Fix script to remove unique constraint on CompetitionSettings type field in AWS
 * Run on AWS: node fix_aws_index.js
 */

require('dotenv').config();
const mongoose = require('mongoose');

const fixIndex = async () => {
  try {
    console.log('🔗 Connecting to MongoDB...');
    console.log('📝 MongoDB URI:', process.env.MONGODB_URI ? '✅ Found' : '❌ Not found');
    
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const db = mongoose.connection.db;
    const collection = db.collection('competitionsettings');

    // List current indexes
    console.log('📋 Current indexes:');
    const indexes = await collection.listIndexes().toArray();
    indexes.forEach((idx, i) => {
      console.log(`   ${i + 1}. ${idx.name}: ${JSON.stringify(idx.key)}`);
    });

    // Drop the unique index on type if it exists
    console.log('\n🔄 Attempting to remove unique index on type...');
    try {
      await collection.dropIndex('type_1');
      console.log('✅ Successfully dropped unique index on type field\n');
    } catch (error) {
      if (error.message.includes('index not found')) {
        console.log('⚠️  Index type_1 not found (may already be removed)\n');
      } else {
        throw error;
      }
    }

    // List indexes after fix
    console.log('📋 Indexes after fix:');
    const newIndexes = await collection.listIndexes().toArray();
    newIndexes.forEach((idx, i) => {
      console.log(`   ${i + 1}. ${idx.name}: ${JSON.stringify(idx.key)}`);
    });

    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    console.log('✅ Index fix completed successfully!');
    console.log('\n💡 You can now create multiple competitions of the same type');
  } catch (error) {
    console.error('❌ Error fixing index:', error.message);
    process.exit(1);
  }
};

fixIndex();
