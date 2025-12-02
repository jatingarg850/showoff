const { publishEvent, publishBatch, TOPICS } = require('../config/kafka');

class KafkaProducerService {
  // User Events
  static async publishUserRegistered(user) {
    return publishEvent(TOPICS.USER_EVENTS, {
      type: 'USER_REGISTERED',
      userId: user._id.toString(),
      username: user.username,
      email: user.email,
      timestamp: new Date().toISOString(),
    });
  }

  static async publishUserLogin(user) {
    return publishEvent(TOPICS.USER_EVENTS, {
      type: 'USER_LOGIN',
      userId: user._id.toString(),
      username: user.username,
      timestamp: new Date().toISOString(),
    });
  }

  static async publishUserProfileUpdated(user) {
    return publishEvent(TOPICS.USER_EVENTS, {
      type: 'USER_PROFILE_UPDATED',
      userId: user._id.toString(),
      username: user.username,
      timestamp: new Date().toISOString(),
    });
  }

  // Notification Events
  static async publishNotification(notification) {
    return publishEvent(TOPICS.NOTIFICATION_EVENTS, {
      type: 'NOTIFICATION_CREATED',
      notificationId: notification._id.toString(),
      userId: notification.user.toString(),
      notificationType: notification.type,
      message: notification.message,
      timestamp: new Date().toISOString(),
    });
  }

  static async publishBulkNotifications(notifications) {
    const events = notifications.map(notification => ({
      type: 'NOTIFICATION_CREATED',
      notificationId: notification._id.toString(),
      userId: notification.user.toString(),
      notificationType: notification.type,
      message: notification.message,
      timestamp: new Date().toISOString(),
    }));
    return publishBatch(TOPICS.NOTIFICATION_EVENTS, events);
  }

  // Post Events
  static async publishPostCreated(post) {
    return publishEvent(TOPICS.POST_EVENTS, {
      type: 'POST_CREATED',
      postId: post._id.toString(),
      userId: post.user.toString(),
      mediaType: post.mediaType,
      timestamp: new Date().toISOString(),
    });
  }

  static async publishPostLiked(post, user) {
    return publishEvent(TOPICS.POST_EVENTS, {
      type: 'POST_LIKED',
      postId: post._id.toString(),
      userId: user._id.toString(),
      postOwnerId: post.user.toString(),
      timestamp: new Date().toISOString(),
    });
  }

  static async publishPostCommented(post, user, comment) {
    return publishEvent(TOPICS.POST_EVENTS, {
      type: 'POST_COMMENTED',
      postId: post._id.toString(),
      commentId: comment._id.toString(),
      userId: user._id.toString(),
      postOwnerId: post.user.toString(),
      timestamp: new Date().toISOString(),
    });
  }

  static async publishPostViewed(post, user) {
    return publishEvent(TOPICS.POST_EVENTS, {
      type: 'POST_VIEWED',
      postId: post._id.toString(),
      userId: user ? user._id.toString() : 'anonymous',
      timestamp: new Date().toISOString(),
    });
  }

  // Transaction Events
  static async publishTransaction(transaction) {
    return publishEvent(TOPICS.TRANSACTION_EVENTS, {
      type: 'TRANSACTION_CREATED',
      transactionId: transaction._id.toString(),
      userId: transaction.user.toString(),
      transactionType: transaction.type,
      amount: transaction.amount,
      balanceAfter: transaction.balanceAfter,
      timestamp: new Date().toISOString(),
    });
  }

  // Video Processing Events
  static async publishVideoUpload(videoData) {
    return publishEvent(TOPICS.VIDEO_PROCESSING, {
      type: 'VIDEO_UPLOADED',
      videoId: videoData.id,
      userId: videoData.userId,
      videoUrl: videoData.url,
      timestamp: new Date().toISOString(),
    });
  }

  static async publishVideoProcessingComplete(videoData) {
    return publishEvent(TOPICS.VIDEO_PROCESSING, {
      type: 'VIDEO_PROCESSING_COMPLETE',
      videoId: videoData.id,
      userId: videoData.userId,
      processedUrl: videoData.processedUrl,
      thumbnailUrl: videoData.thumbnailUrl,
      timestamp: new Date().toISOString(),
    });
  }

  // Analytics Events
  static async publishAnalyticsEvent(eventType, data) {
    return publishEvent(TOPICS.ANALYTICS_EVENTS, {
      type: eventType,
      ...data,
      timestamp: new Date().toISOString(),
    });
  }

  // Email Events
  static async publishEmailEvent(emailData) {
    return publishEvent(TOPICS.EMAIL_EVENTS, {
      type: 'EMAIL_SEND_REQUESTED',
      to: emailData.to,
      subject: emailData.subject,
      template: emailData.template,
      data: emailData.data,
      timestamp: new Date().toISOString(),
    });
  }

  // SMS Events
  static async publishSMSEvent(smsData) {
    return publishEvent(TOPICS.SMS_EVENTS, {
      type: 'SMS_SEND_REQUESTED',
      to: smsData.to,
      message: smsData.message,
      timestamp: new Date().toISOString(),
    });
  }
}

module.exports = KafkaProducerService;
