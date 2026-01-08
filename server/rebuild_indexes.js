const mongoose = require('mongoose');
const User = require('./models/User');

async function rebuildIndexes() {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/showofftest';
    
    console.log('🔄 Connecting to MongoDB...');
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB\n');

    // Drop all indexes on User collection
    console.log('🗑️  Dropping all indexes on User collection...');
    await User.collection.dropIndexes();
    console.log('✅ All indexes dropped\n');

    // Rebuild indexes from schema
    console.log('🔨 Rebuilding indexes from schema...');
    await User.syncIndexes();
    console.log('✅ Indexes rebuilt\n');

    // List all indexes
    console.log('📋 Current indexes on User collection:');
    const indexes = await User.collection.getIndexes();
    Object.keys(indexes).forEach(indexName => {
      console.log(`   - ${indexName}:`, indexes[indexName]);
    });

    console.log('\n✨ Index rebuild complete!');
    console.log('📝 Phone field now has unique constraint\n');

    await mongoose.connection.close();
    console.log('🔌 Connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

rebuildIndexes();
