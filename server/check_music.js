const mongoose = require('mongoose');
const Music = require('./models/Music');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(async () => {
  console.log('Connected to MongoDB');
  
  // Check if music exists
  const count = await Music.countDocuments();
  console.log('Total music in DB:', count);
  
  // Get first music
  const music = await Music.findOne();
  if (music) {
    console.log('First music:', {
      _id: music._id,
      title: music.title,
      isApproved: music.isApproved,
      isActive: music.isActive,
    });
    
    // Approve it if not approved
    if (!music.isApproved) {
      console.log('\nApproving music...');
      music.isApproved = true;
      await music.save();
      console.log('✅ Music approved');
    }
  } else {
    console.log('No music found - creating sample music...');
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
  }
  
  process.exit(0);
}).catch(err => {
  console.error('Connection error:', err);
  process.exit(1);
});
