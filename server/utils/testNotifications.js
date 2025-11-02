const { createNotification } = require('../controllers/notificationController');
const User = require('../models/User');

// Test function to create sample notifications
const createTestNotifications = async (userId) => {
  try {
    console.log(`Creating test notifications for user: ${userId}`);
    
    // Create some test notifications
    const testNotifications = [
      {
        recipient: userId,
        sender: userId, // Self notification for testing
        type: 'system',
        title: 'Welcome to ShowOff.life!',
        message: 'Your account has been set up successfully. Start sharing your talents!',
        data: {},
      },
      {
        recipient: userId,
        sender: userId,
        type: 'achievement',
        title: 'First Login Achievement',
        message: 'You\'ve successfully logged in for the first time!',
        data: {
          metadata: { achievementType: 'first_login' },
        },
      },
      {
        recipient: userId,
        sender: userId,
        type: 'system',
        title: 'Notification System Active',
        message: 'Real-time notifications are now working! You\'ll receive instant updates.',
        data: {},
      },
    ];
    
    // Create notifications with delay to see them arrive
    for (let i = 0; i < testNotifications.length; i++) {
      setTimeout(async () => {
        await createNotification(testNotifications[i]);
        console.log(`✅ Test notification ${i + 1} created`);
      }, i * 2000); // 2 second delay between notifications
    }
    
    console.log('✅ Test notifications scheduled');
    return true;
  } catch (error) {
    console.error('❌ Error creating test notifications:', error);
    return false;
  }
};

// Create a like notification (for testing)
const createTestLikeNotification = async (userId) => {
  try {
    await createNotification({
      recipient: userId,
      sender: userId,
      type: 'like',
      title: 'New Like',
      message: 'liked your post',
      data: {
        postId: 'test_post_123',
      },
    });
    console.log('✅ Test like notification created');
  } catch (error) {
    console.error('❌ Error creating test like notification:', error);
  }
};

// Create a comment notification (for testing)
const createTestCommentNotification = async (userId) => {
  try {
    await createNotification({
      recipient: userId,
      sender: userId,
      type: 'comment',
      title: 'New Comment',
      message: 'commented: "This is amazing! 🔥"',
      data: {
        postId: 'test_post_123',
        commentId: 'test_comment_456',
      },
    });
    console.log('✅ Test comment notification created');
  } catch (error) {
    console.error('❌ Error creating test comment notification:', error);
  }
};

// Create a follow notification (for testing)
const createTestFollowNotification = async (userId) => {
  try {
    await createNotification({
      recipient: userId,
      sender: userId,
      type: 'follow',
      title: 'New Follower',
      message: 'started following you',
      data: {},
    });
    console.log('✅ Test follow notification created');
  } catch (error) {
    console.error('❌ Error creating test follow notification:', error);
  }
};

module.exports = {
  createTestNotifications,
  createTestLikeNotification,
  createTestCommentNotification,
  createTestFollowNotification,
};