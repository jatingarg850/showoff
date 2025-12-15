const { createNotification } = require('../controllers/notificationController');
const { sendWebSocketNotification } = require('./pushNotifications');

// Helper functions to create different types of notifications

// Like notification
exports.createLikeNotification = async (postId, likerId, postOwnerId) => {
  if (likerId === postOwnerId.toString()) {
    console.log('Skipping like notification - user liked own post');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating like notification: post=${postId}, liker=${likerId}, owner=${postOwnerId}`);
    console.log(`  Recipient type: ${typeof postOwnerId}, value: ${postOwnerId.toString()}`);
    
    await createNotification({
      recipient: postOwnerId,
      sender: likerId,
      type: 'like',
      title: 'New Like',
      message: 'liked your reel',
      data: {
        postId: postId.toString(),
      },
    });
    
    console.log('✅ Like notification created successfully');
  } catch (error) {
    console.error('❌ Error creating like notification:', error);
  }
};

// Comment notification
exports.createCommentNotification = async (postId, commentId, commenterId, postOwnerId, commentText) => {
  if (commenterId === postOwnerId.toString()) {
    console.log('Skipping comment notification - user commented on own post');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating comment notification: post=${postId}, commenter=${commenterId}, owner=${postOwnerId}`);
    
    const truncatedComment = commentText.length > 50 
      ? commentText.substring(0, 50) + '...' 
      : commentText;
    
    await createNotification({
      recipient: postOwnerId,
      sender: commenterId,
      type: 'comment',
      title: 'New Comment',
      message: `commented: "${truncatedComment}"`,
      data: {
        postId: postId.toString(),
        commentId: commentId.toString(),
      },
    });
    
    console.log('✅ Comment notification created successfully');
  } catch (error) {
    console.error('❌ Error creating comment notification:', error);
  }
};

// Follow notification
exports.createFollowNotification = async (followerId, followedId) => {
  if (followerId === followedId.toString()) {
    console.log('Skipping follow notification - user followed themselves');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating follow notification: follower=${followerId}, followed=${followedId}`);
    
    await createNotification({
      recipient: followedId,
      sender: followerId,
      type: 'follow',
      title: 'New Follower',
      message: 'started following you',
      data: {},
    });
    
    console.log('✅ Follow notification created successfully');
  } catch (error) {
    console.error('❌ Error creating follow notification:', error);
  }
};

// SYT vote notification
exports.createVoteNotification = async (sytEntryId, voterId, entryOwnerId) => {
  if (voterId === entryOwnerId.toString()) {
    console.log('Skipping vote notification - user voted for own entry');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating vote notification: entry=${sytEntryId}, voter=${voterId}, owner=${entryOwnerId}`);
    
    await createNotification({
      recipient: entryOwnerId,
      sender: voterId,
      type: 'vote',
      title: 'New Vote',
      message: 'voted for your SYT entry',
      data: {
        sytEntryId: sytEntryId.toString(),
      },
    });
    
    console.log('✅ Vote notification created successfully');
  } catch (error) {
    console.error('❌ Error creating vote notification:', error);
  }
};

// Gift notification
exports.createGiftNotification = async (senderId, recipientId, giftType, amount) => {
  try {
    console.log(`Creating gift notification: sender=${senderId}, recipient=${recipientId}, amount=${amount}`);
    
    await createNotification({
      recipient: recipientId,
      sender: senderId,
      type: 'gift',
      title: 'Gift Received',
      message: `sent you ${amount} ${giftType}`,
      data: {
        amount,
        metadata: { giftType },
      },
    });
    
    console.log('✅ Gift notification created successfully');
  } catch (error) {
    console.error('❌ Error creating gift notification:', error);
  }
};

// Achievement notification
exports.createAchievementNotification = async (userId, achievementTitle, achievementDescription) => {
  try {
    console.log(`Creating achievement notification: user=${userId}, title=${achievementTitle}`);
    
    await createNotification({
      recipient: userId,
      sender: userId, // System notification
      type: 'achievement',
      title: 'Achievement Unlocked!',
      message: `${achievementTitle}: ${achievementDescription}`,
      data: {
        metadata: { achievementTitle, achievementDescription },
      },
    });
    
    console.log('✅ Achievement notification created successfully');
  } catch (error) {
    console.error('❌ Error creating achievement notification:', error);
  }
};

// System notification
exports.createSystemNotification = async (userId, title, message, data = {}) => {
  try {
    console.log(`Creating system notification: user=${userId}, title=${title}`);
    
    await createNotification({
      recipient: userId,
      sender: userId, // System notification
      type: 'system',
      title,
      message,
      data: {
        metadata: data,
      },
    });
    
    console.log('✅ System notification created successfully');
  } catch (error) {
    console.error('❌ Error creating system notification:', error);
  }
};

// Bulk system notification
exports.createBulkSystemNotification = async (userIds, title, message, data = {}) => {
  try {
    console.log(`Creating bulk system notification for ${userIds.length} users`);
    
    const notifications = userIds.map(userId => ({
      recipient: userId,
      sender: userId, // System notification
      type: 'system',
      title,
      message,
      data: {
        metadata: data,
      },
    }));
    
    const Notification = require('../models/Notification');
    await Notification.insertMany(notifications);
    
    // Send WebSocket notifications
    const { sendBulkWebSocketNotification } = require('./pushNotifications');
    await sendBulkWebSocketNotification(userIds, {
      type: 'system',
      title,
      message,
      data,
    });
    
    console.log(`✅ Bulk system notification sent to ${userIds.length} users`);
  } catch (error) {
    console.error('❌ Error creating bulk system notification:', error);
  }
};

// Mention notification
exports.createMentionNotification = async (postId, mentionerId, mentionedUserId, context) => {
  if (mentionerId === mentionedUserId.toString()) {
    console.log('Skipping mention notification - user mentioned themselves');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating mention notification: post=${postId}, mentioner=${mentionerId}, mentioned=${mentionedUserId}`);
    
    await createNotification({
      recipient: mentionedUserId,
      sender: mentionerId,
      type: 'mention',
      title: 'You were mentioned',
      message: `mentioned you in a ${context}`,
      data: {
        postId: postId.toString(),
        metadata: { context },
      },
    });
    
    console.log('✅ Mention notification created successfully');
  } catch (error) {
    console.error('❌ Error creating mention notification:', error);
  }
};

// Share notification
exports.createShareNotification = async (postId, sharerId, postOwnerId) => {
  if (sharerId === postOwnerId.toString()) {
    console.log('Skipping share notification - user shared own post');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating share notification: post=${postId}, sharer=${sharerId}, owner=${postOwnerId}`);
    
    await createNotification({
      recipient: postOwnerId,
      sender: sharerId,
      type: 'share',
      title: 'Post Shared',
      message: 'shared your reel',
      data: {
        postId: postId.toString(),
      },
    });
    
    console.log('✅ Share notification created successfully');
  } catch (error) {
    console.error('❌ Error creating share notification:', error);
  }
};

// Message notification
exports.createMessageNotification = async (senderId, recipientId, messageText) => {
  if (senderId === recipientId.toString()) {
    console.log('Skipping message notification - user messaged themselves');
    return; // Don't notify self
  }
  
  try {
    console.log(`Creating message notification: sender=${senderId}, recipient=${recipientId}`);
    
    const truncatedMessage = messageText.length > 50 
      ? messageText.substring(0, 50) + '...' 
      : messageText;
    
    await createNotification({
      recipient: recipientId,
      sender: senderId,
      type: 'message',
      title: 'New Message',
      message: truncatedMessage,
      data: {
        senderId: senderId.toString(),
      },
    });
    
    console.log('✅ Message notification created successfully');
  } catch (error) {
    console.error('❌ Error creating message notification:', error);
  }
};