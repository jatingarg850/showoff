// Custom WebSocket-based notification system (no Firebase)

// Store active WebSocket connections
const activeConnections = new Map();

// Send real-time notification via WebSocket
exports.sendWebSocketNotification = async (userId, notification) => {
  try {
    // Get io instance from global (set in server.js)
    const io = global.io;

    if (!io) {
      console.error('❌ Socket.IO not initialized - io is null/undefined');
      console.error('   Make sure server.js has set global.io');
      return false;
    }

    // Convert notification to plain object if it's a Mongoose document
    const notificationData = notification.toObject ? notification.toObject() : notification;
    
    // Send to specific user room
    const roomName = `user_${userId}`;
    io.to(roomName).emit('newNotification', {
      notification: notificationData,
      timestamp: new Date().toISOString(),
    });
    
    console.log(`✅ WebSocket notification sent to user ${userId} in room ${roomName}`);
    console.log(`   Type: ${notificationData.type}, Title: ${notificationData.title}`);
    return true;
  } catch (error) {
    console.error('❌ Error sending WebSocket notification:', error.message);
    console.error('   Stack:', error.stack);
    return false;
  }
};

// Send notification to multiple users via WebSocket
exports.sendBulkWebSocketNotification = async (userIds, notificationData) => {
  try {
    const io = require('../server').io;
    if (io) {
      userIds.forEach(userId => {
        io.to(`user_${userId}`).emit('newNotification', {
          notification: notificationData,
          timestamp: new Date().toISOString(),
        });
      });
      
      console.log(`✅ Bulk WebSocket notification sent to ${userIds.length} users`);
      return true;
    }
    return false;
  } catch (error) {
    console.error('Error sending bulk WebSocket notification:', error);
    return false;
  }
};

// Send system-wide broadcast
exports.sendSystemBroadcast = async (notificationData) => {
  try {
    const io = require('../server').io;
    if (io) {
      io.emit('systemNotification', {
        notification: notificationData,
        timestamp: new Date().toISOString(),
      });
      
      console.log('✅ System broadcast sent to all connected users');
      return true;
    }
    return false;
  } catch (error) {
    console.error('Error sending system broadcast:', error);
    return false;
  }
};

// Custom in-app notification system (alternative to push notifications)
exports.sendInAppNotification = async (user, notification) => {
  try {
    if (!user.notificationSettings?.push) {
      console.log(`In-app notifications disabled for user ${user.username}`);
      return false;
    }

    // Send via WebSocket for real-time delivery
    const sent = await exports.sendWebSocketNotification(user._id, notification);
    
    if (sent) {
      console.log(`✅ In-app notification sent to user ${user.username}`);
    }
    
    return sent;
  } catch (error) {
    console.error('Error sending in-app notification:', error);
    return false;
  }
};

// Store user connection for targeted notifications
exports.registerUserConnection = (userId, socketId) => {
  activeConnections.set(userId, socketId);
  console.log(`✅ User ${userId} connected with socket ${socketId}`);
};

// Remove user connection
exports.unregisterUserConnection = (userId) => {
  activeConnections.delete(userId);
  console.log(`✅ User ${userId} disconnected`);
};

// Get active connections count
exports.getActiveConnectionsCount = () => {
  return activeConnections.size;
};

// Check if user is online
exports.isUserOnline = (userId) => {
  return activeConnections.has(userId);
};