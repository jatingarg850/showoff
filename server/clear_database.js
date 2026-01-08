const mongoose = require('mongoose');

async function clearDatabase() {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/showofftest';
    
    console.log('🔄 Connecting to MongoDB...');
    console.log('📍 Database URI:', mongoUri);

    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB');

    // Get all collections
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log(`\n📊 Found ${collections.length} collections:`);
    collections.forEach(col => console.log(`   - ${col.name}`));

    // Drop all collections
    console.log('\n🗑️  Clearing all collections...');
    for (const collection of collections) {
      await mongoose.connection.db.collection(collection.name).deleteMany({});
      console.log(`   ✅ Cleared: ${collection.name}`);
    }

    console.log('\n✨ Database cleared successfully!');
    console.log('📝 All collections are now empty and ready for fresh data.\n');

    await mongoose.connection.close();
    console.log('🔌 Connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error clearing database:', error.message);
    process.exit(1);
  }
}

clearDatabase();
