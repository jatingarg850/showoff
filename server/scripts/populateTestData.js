require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const SYTEntry = require('../models/SYTEntry');
const DailySelfie = require('../models/DailySelfie');

const connectDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

const createTestUsers = async () => {
  const testUsers = [
    {
      username: 'alex_talent',
      displayName: 'Alex Rodriguez',
      email: 'alex@test.com',
      password: 'hashedpassword',
      isVerified: true,
      referralCode: 'ALEX001',
    },
    {
      username: 'sarah_star',
      displayName: 'Sarah Johnson',
      email: 'sarah@test.com',
      password: 'hashedpassword',
      isVerified: true,
      referralCode: 'SARAH002',
    },
    {
      username: 'mike_creator',
      displayName: 'Mike Chen',
      email: 'mike@test.com',
      password: 'hashedpassword',
      isVerified: false,
      referralCode: 'MIKE003',
    },
    {
      username: 'emma_artist',
      displayName: 'Emma Wilson',
      email: 'emma@test.com',
      password: 'hashedpassword',
      isVerified: true,
      referralCode: 'EMMA004',
    },
    {
      username: 'david_dancer',
      displayName: 'David Brown',
      email: 'david@test.com',
      password: 'hashedpassword',
      isVerified: false,
      referralCode: 'DAVID005',
    },
  ];

  const createdUsers = [];
  for (const userData of testUsers) {
    try {
      const existingUser = await User.findOne({ username: userData.username });
      if (!existingUser) {
        const user = await User.create(userData);
        createdUsers.push(user);
        console.log(`Created user: ${user.username}`);
      } else {
        createdUsers.push(existingUser);
        console.log(`User already exists: ${existingUser.username}`);
      }
    } catch (error) {
      console.error(`Error creating user ${userData.username}:`, error);
    }
  }

  return createdUsers;
};

const createSYTEntries = async (users) => {
  const getCurrentPeriod = (type) => {
    const now = new Date();
    const year = now.getFullYear();
    
    if (type === 'weekly') {
      const week = Math.ceil((now - new Date(year, 0, 1)) / (7 * 24 * 60 * 60 * 1000));
      return `${year}-W${week.toString().padStart(2, '0')}`;
    }
  };

  const sytEntries = [
    {
      user: users[0]._id,
      title: 'Amazing Dance Performance',
      description: 'Check out my latest dance routine!',
      category: 'dancing',
      videoUrl: '/uploads/test-video1.mp4',
      competitionType: 'weekly',
      competitionPeriod: getCurrentPeriod('weekly'),
      votesCount: 245,
      coinsEarned: 245,
      isApproved: true,
    },
    {
      user: users[1]._id,
      title: 'Singing Cover',
      description: 'My cover of a popular song',
      category: 'singing',
      videoUrl: '/uploads/test-video2.mp4',
      competitionType: 'weekly',
      competitionPeriod: getCurrentPeriod('weekly'),
      votesCount: 189,
      coinsEarned: 189,
      isApproved: true,
    },
    {
      user: users[2]._id,
      title: 'Art Creation Process',
      description: 'Time-lapse of my latest artwork',
      category: 'art',
      videoUrl: '/uploads/test-video3.mp4',
      competitionType: 'weekly',
      competitionPeriod: getCurrentPeriod('weekly'),
      votesCount: 156,
      coinsEarned: 156,
      isApproved: true,
    },
    {
      user: users[3]._id,
      title: 'Comedy Skit',
      description: 'A funny skit I created',
      category: 'comedy',
      videoUrl: '/uploads/test-video4.mp4',
      competitionType: 'weekly',
      competitionPeriod: getCurrentPeriod('weekly'),
      votesCount: 134,
      coinsEarned: 134,
      isApproved: true,
    },
    {
      user: users[4]._id,
      title: 'Magic Trick',
      description: 'Mind-blowing magic performance',
      category: 'other',
      videoUrl: '/uploads/test-video5.mp4',
      competitionType: 'weekly',
      competitionPeriod: getCurrentPeriod('weekly'),
      votesCount: 98,
      coinsEarned: 98,
      isApproved: true,
    },
  ];

  for (const entryData of sytEntries) {
    try {
      const existingEntry = await SYTEntry.findOne({
        user: entryData.user,
        competitionPeriod: entryData.competitionPeriod,
      });
      
      if (!existingEntry) {
        const entry = await SYTEntry.create(entryData);
        console.log(`Created SYT entry: ${entry.title}`);
      } else {
        console.log(`SYT entry already exists for user in this period`);
      }
    } catch (error) {
      console.error(`Error creating SYT entry:`, error);
    }
  }
};

const createDailySelfies = async (users) => {
  const getTodayDateString = () => {
    const today = new Date();
    return today.toISOString().split('T')[0];
  };

  const getYesterdayDateString = () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return yesterday.toISOString().split('T')[0];
  };

  const themes = ['Golden Hour Glow', 'Mirror Selfie', 'Nature Background', 'Smile Challenge', 'Creative Angle'];

  const dailySelfies = [
    {
      user: users[0]._id,
      imageUrl: '/uploads/selfie1.jpg',
      challengeDate: getTodayDateString(),
      theme: themes[0],
      votesCount: 45,
    },
    {
      user: users[1]._id,
      imageUrl: '/uploads/selfie2.jpg',
      challengeDate: getTodayDateString(),
      theme: themes[0],
      votesCount: 38,
    },
    {
      user: users[2]._id,
      imageUrl: '/uploads/selfie3.jpg',
      challengeDate: getTodayDateString(),
      theme: themes[0],
      votesCount: 32,
    },
    {
      user: users[3]._id,
      imageUrl: '/uploads/selfie4.jpg',
      challengeDate: getYesterdayDateString(),
      theme: themes[1],
      votesCount: 28,
    },
    {
      user: users[4]._id,
      imageUrl: '/uploads/selfie5.jpg',
      challengeDate: getYesterdayDateString(),
      theme: themes[1],
      votesCount: 22,
    },
  ];

  for (const selfieData of dailySelfies) {
    try {
      const existingSelfie = await DailySelfie.findOne({
        user: selfieData.user,
        challengeDate: selfieData.challengeDate,
      });
      
      if (!existingSelfie) {
        const selfie = await DailySelfie.create(selfieData);
        console.log(`Created daily selfie for ${selfie.challengeDate}`);
      } else {
        console.log(`Daily selfie already exists for user on ${selfieData.challengeDate}`);
      }
    } catch (error) {
      console.error(`Error creating daily selfie:`, error);
    }
  }
};

const populateTestData = async () => {
  try {
    await connectDatabase();
    
    console.log('Creating test users...');
    const users = await createTestUsers();
    
    console.log('Creating SYT entries...');
    await createSYTEntries(users);
    
    console.log('Creating daily selfies...');
    await createDailySelfies(users);
    
    console.log('Test data population completed!');
    process.exit(0);
  } catch (error) {
    console.error('Error populating test data:', error);
    process.exit(1);
  }
};

populateTestData();