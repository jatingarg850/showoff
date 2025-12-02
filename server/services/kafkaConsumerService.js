const { subscribe, TOPICS } = require('../config/kafka');
const { sendPushNotification } = require('../utils/pushNotifications');
const { sendFCMNotification } = require('../utils/fcmService');

class KafkaConsumerService {
  static async startConsumers() {
    console.log('🎧 Starting Kafka consumers...');

    // Subscribe to all topics
    await subscribe(
      Object.values(TOPICS),
      this.handleMessage.bind(this)
    );
  }

  static async handleMessage(topic, event, metadata) {
    console.log(`📨 Received event from ${topic}:`, event.type);

    try {
      switch (topic) {
        case TOPICS.USER_EVENTS:
          await this.handleUserEvent(event);
          break;
        case TOPICS.NOTIFICATION_EVENTS:
          await this.handleNotificationEvent(event);
          break;
        case TOPICS.POST_EVENTS:
          await this.handlePostEvent(event);
          break;
        case TOPICS.TRANSACTION_EVENTS:
          await this.handleTransactionEvent(event);
          break;
        case TOPICS.VIDEO_PROCESSING:
          await this.handleVideoProcessingEvent(event);
          break;
        case TOPICS.ANALYTICS_EVENTS:
          await this.handleAnalyticsEvent(event);
          break;
        case TOPICS.EMAIL_EVENTS:
          await this.handleEmailEvent(event);
          break;
        case TOPICS.SMS_EVENTS:
          await this.handleSMSEvent(event);
          break;
        default:
          console.log(`⚠️  Unknown topic: ${topic}`);
      }
    } catch (error) {
      console.error(`❌ Error handling ${topic} event:`, error);
    }
  }

  // User Event Handlers
  static async handleUserEvent(event) {
    switch (event.type) {
      case 'USER_REGISTERED':
        console.log(`✅ User registered: ${event.username}`);
        // Send welcome email, analytics, etc.
        break;
      case 'USER_LOGIN':
        console.log(`✅ User logged in: ${event.username}`);
        // Track login analytics
        break;
      case 'USER_PROFILE_UPDATED':
        console.log(`✅ User profile updated: ${event.username}`);
        break;
    }
  }

  // Notification Event Handlers
  static async handleNotificationEvent(event) {
    if (event.type === 'NOTIFICATION_CREATED') {
      console.log(`📬 Sending notification to user: ${event.userId}`);
      
      // Send push notification via FCM
      try {
        await sendFCMNotification(event.userId, {
          title: 'ShowOff.life',
          body: event.message,
          data: {
            notificationId: event.notificationId,
            type: event.notificationType,
          },
        });
      } catch (error) {
        console.error('Failed to send FCM notification:', error);
      }

      // Send via WebSocket if available
      try {
        if (global.io) {
          global.io.to(event.userId).emit('notification', {
            id: event.notificationId,
            message: event.message,
            type: event.notificationType,
            timestamp: event.timestamp,
          });
        }
      } catch (error) {
        console.error('Failed to send WebSocket notification:', error);
      }
    }
  }

  // Post Event Handlers
  static async handlePostEvent(event) {
    switch (event.type) {
      case 'POST_CREATED':
        console.log(`📝 Post created: ${event.postId}`);
        // Update feed cache, notify followers, etc.
        break;
      case 'POST_LIKED':
        console.log(`❤️  Post liked: ${event.postId}`);
        // Update like count, notify post owner
        break;
      case 'POST_COMMENTED':
        console.log(`💬 Post commented: ${event.postId}`);
        // Notify post owner and mentioned users
        break;
      case 'POST_VIEWED':
        console.log(`👁️  Post viewed: ${event.postId}`);
        // Update view analytics
        break;
    }
  }

  // Transaction Event Handlers
  static async handleTransactionEvent(event) {
    if (event.type === 'TRANSACTION_CREATED') {
      console.log(`💰 Transaction created: ${event.transactionType} - ${event.amount} coins`);
      // Update user balance cache, send receipt, analytics
    }
  }

  // Video Processing Event Handlers
  static async handleVideoProcessingEvent(event) {
    switch (event.type) {
      case 'VIDEO_UPLOADED':
        console.log(`🎥 Video uploaded: ${event.videoId}`);
        // Start video processing pipeline
        break;
      case 'VIDEO_PROCESSING_COMPLETE':
        console.log(`✅ Video processing complete: ${event.videoId}`);
        // Notify user, update post status
        break;
    }
  }

  // Analytics Event Handlers
  static async handleAnalyticsEvent(event) {
    console.log(`📊 Analytics event: ${event.type}`);
    // Store in analytics database, update dashboards
  }

  // Email Event Handlers
  static async handleEmailEvent(event) {
    if (event.type === 'EMAIL_SEND_REQUESTED') {
      console.log(`📧 Sending email to: ${event.to}`);
      // Send email via email service (SendGrid, AWS SES, etc.)
    }
  }

  // SMS Event Handlers
  static async handleSMSEvent(event) {
    if (event.type === 'SMS_SEND_REQUESTED') {
      console.log(`📱 Sending SMS to: ${event.to}`);
      // Send SMS via SMS service (Twilio, AWS SNS, etc.)
    }
  }
}

module.exports = KafkaConsumerService;
