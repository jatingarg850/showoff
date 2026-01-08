const mongoose = require('mongoose');
const Music = require('./models/Music');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff').then(async () => {
  console.log('Connected');
  
  // Test 1: Find all music
  const all = await Music.find({});
  console.log('All music count:', all.length);
  
  // Test 2: Find approved music
  const approved = await Music.find({ isApproved: true, isActive: true });
  console.log('Approved music count:', approved.length);
  
  // Test 3: Count documents
  const count = await Music.countDocuments({ isApproved: true, isActive: true });
  console.log('Count documents result:', count);
  
  // Test 4: Show first music
  if (all.length > 0) {
    console.log('First music:', {
      _id: all[0]._id,
      title: all[0].title,
      isApproved: all[0].isApproved,
      isActive: all[0].isActive,
    });
  }
  
  process.exit(0);
}).catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
