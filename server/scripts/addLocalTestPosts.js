const mongoose = require('mongoose');
const User = require('../models/User');
const Post = require('../models/Post');
const fs = require('fs');
const path = require('path');

async function addLocalTestPosts() {
  try {
    // Connect to database
    await mongoose.connect('mongodb://localhost:27017/showoff-life');
    console.log('Connected to MongoDB');

    // Get existing users
    const users = await User.find().limit(5);
    if (users.length === 0) {
      console.log('No users found. Please create some users first.');
      return;
    }

    // Check what local media files exist
    const uploadsDir = path.join(__dirname, '..', 'uploads');
    const videosDir = path.join(uploadsDir, 'videos');
    const imagesDir = path.join(uploadsDir, 'images');

    let videoFiles = [];
    let imageFiles = [];

    if (fs.existsSync(videosDir)) {
      videoFiles = fs.readdirSync(videosDir).filter(file => 
        file.endsWith('.mp4') || file.endsWith('.mov') || file.endsWith('.avi')
      );
    }

    if (fs.existsSync(imagesDir)) {
      imageFiles = fs.readdirSync(imagesDir).filter(file => 
        file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png') || file.endsWith('.gif')
      );
    }

    console.log(`Found ${videoFiles.length} video files and ${imageFiles.length} image files`);

    const testPosts = [];

    // Create posts with local video files
    videoFiles.slice(0, 3).forEach((videoFile, index) => {
      testPosts.push({
        user: users[index % users.length]._id,
        type: 'video',
        mediaUrl: `/uploads/videos/${videoFile}`,
        caption: `Test video post ${index + 1} - Local media file`,
        hashtags: ['test', 'local', 'video'],
        likesCount: Math.floor(Math.random() * 100),
        commentsCount: Math.floor(Math.random() * 20),
        viewsCount: Math.floor(Math.random() * 500),
        sharesCount: Math.floor(Math.random() * 10),
        isActive: true,
        visibility: 'public'
      });
    });

    // Create posts with local image files
    imageFiles.slice(0, 3).forEach((imageFile, index) => {
      testPosts.push({
        user: users[index % users.length]._id,
        type: 'image',
        mediaUrl: `/uploads/images/${imageFile}`,
        caption: `Test image post ${index + 1} - Local media file`,
        hashtags: ['test', 'local', 'image'],
        likesCount: Math.floor(Math.random() * 100),
        commentsCount: Math.floor(Math.random() * 20),
        viewsCount: Math.floor(Math.random() * 500),
        sharesCount: Math.floor(Math.random() * 10),
        isActive: true,
        visibility: 'public'
      });
    });

    if (testPosts.length > 0) {
      // Insert test posts
      const createdPosts = await Post.insertMany(testPosts);
      console.log(`✅ Created ${createdPosts.length} test posts with local media`);

      // Update user post counts
      for (const user of users) {
        const userPostCount = await Post.countDocuments({ user: user._id });
        await User.findByIdAndUpdate(user._id, { postsCount: userPostCount });
      }

      console.log('✅ Updated user post counts');
    } else {
      console.log('❌ No local media files found to create test posts');
    }

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

addLocalTestPosts();