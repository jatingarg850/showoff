const mongoose = require('mongoose');
const Music = require('./models/Music');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff').then(async () => {
  console.log('Connected');
  const music = await Music.find({});
  console.log('All music:', JSON.stringify(music, null, 2));
  process.exit(0);
}).catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
