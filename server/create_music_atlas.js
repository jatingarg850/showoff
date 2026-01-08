const mongoose = require('mongoose');
const Music = require('./models/Music');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff';

mongoose.connect(MONGODB_URI).then(async () => {
  console.log('Connected to MongoDB Atlas');
  
  // Check if music exists
  const count = await Music.countDocuments();
  console.log('Total music in DB:', count);
  
  if (count === 0) {
    console.log('Creating sample music...');
    const newMusic = new Music({
      title: 'Test Music',
      artist: 'Test Artist',
      audioUrl: '/uploads/music/test.mp3',
      duration: 180,
      genre: 'pop',
      mood: 'happy',
      isApproved: true,
      isActive: true,
    });
    await newMusic.save();
    console.log('✅ Sample music created:', newMusic._id);
  } else {
    console.log('Music already exists');
    const music = await Music.findOne();
    console.log('First music:', {
      _id: music._id,
      title: music.title,
      isApproved: music.isApproved,
      isActive: music.isActive,
    });
  }
  
  process.exit(0);
}).catch(err => {
  console.error('Connection error:', err.message);
  process.exit(1);
});
