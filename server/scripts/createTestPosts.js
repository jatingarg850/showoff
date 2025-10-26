require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Post = require('../models/Post');

const connectDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

const createTestPosts = async () => {
  try {
    await connectDatabase();
    
    // Get existing users
    const users = await User.find().limit(5);
    
    if (users.length === 0) {
      console.log('No users found. Please create users first.');
      process.exit(1);
    }
    
    console.log(`Found ${users.length} users`);
    
    const testPosts = [
      {
        user: users[0]._id,
        type: 'reel',
        mediaUrl: '/uploads/reel1.mp4',
        caption: 'Amazing dance performance! 💃✨',
        hashtags: ['dance', 'performance', 'amazing'],
        likesCount: 1250,
        commentsCount: 89,
        sharesCount: 45,
        viewsCount: 5600,
      },
      {
        user: users[1]._id,
        type: 'reel',
        mediaUrl: '/uploads/reel2.mp4',
        caption: 'Sunset vibes from the mountains 🌅',
        hashtags: ['sunset', 'mountains', 'nature'],
        likesCount: 892,
        commentsCount: 156,
        sharesCount: 78,
        viewsCount: 3400,
      },
      {
        user: users[2]._id,
        type: 'reel',
        mediaUrl: '/uploads/reel3.mp4',
        caption: 'Cooking something delicious! 👨‍🍳🔥',
        hashtags: ['cooking', 'food', 'delicious'],
        likesCount: 567,
        commentsCount: 234,
        sharesCount: 123,
        viewsCount: 2800,
      },
      {
        user: users[3]._id,
        type: 'reel',
        mediaUrl: '/uploads/reel4.mp4',
        caption: 'Street art in the city 🎨',
        hashtags: ['art', 'street', 'creative'],
        likesCount: 445,
        commentsCount: 67,
        sharesCount: 34,
        viewsCount: 1900,
      },
      {
        user: users[4]._id,
        type: 'reel',
        mediaUrl: '/uploads/reel5.mp4',
        caption: 'Morning workout routine 💪',
        hashtags: ['fitness', 'workout', 'morning'],
        likesCount: 723,
        commentsCount: 98,
        sharesCount: 56,
        viewsCount: 3200,
      },
    ];
    
    for (const postData of testPosts) {
      try {
        const existingPost = await Post.findOne({
          user: postData.user,
          caption: postData.caption,
        });
        
        if (!existingPost) {
          const post = await Post.create(postData);
          console.log(`Created post: ${post.caption}`);
        } else {
          console.log(`Post already exists: ${postData.caption}`);
        }
      } catch (error) {
        console.error(`Error creating post:`, error);
      }
    }
    
    console.log('Test posts creation completed!');
    process.exit(0);
  } catch (error) {
    console.error('Error creating test posts:', error);
    process.exit(1);
  }
};

createTestPosts();