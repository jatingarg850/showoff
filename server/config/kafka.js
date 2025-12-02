const { Kafka, logLevel } = require('kafkajs');

// Kafka Configuration
const kafka = new Kafka({
  clientId: 'showoff-life-server',
  brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
  logLevel: logLevel.ERROR,
  retry: {
    initialRetryTime: 100,
    retries: 8,
  },
  connectionTimeout: 10000,
  requestTimeout: 30000,
});

// Create Producer
const producer = kafka.producer({
  allowAutoTopicCreation: true,
  transactionTimeout: 30000,
});

// Create Consumer
const consumer = kafka.consumer({
  groupId: process.env.KAFKA_CONSUMER_GROUP || 'showoff-life-consumer-group',
  sessionTimeout: 30000,
  heartbeatInterval: 3000,
});

// Create Admin Client
const admin = kafka.admin();

// Topic Configuration
const TOPICS = {
  USER_EVENTS: 'user-events',
  NOTIFICATION_EVENTS: 'notification-events',
  POST_EVENTS: 'post-events',
  TRANSACTION_EVENTS: 'transaction-events',
  VIDEO_PROCESSING: 'video-processing',
  ANALYTICS_EVENTS: 'analytics-events',
  EMAIL_EVENTS: 'email-events',
  SMS_EVENTS: 'sms-events',
};

// Initialize Kafka
let isConnected = false;

const connectProducer = async () => {
  try {
    await producer.connect();
    console.log('✅ Kafka Producer connected');
    isConnected = true;
  } catch (error) {
    console.error('❌ Kafka Producer connection failed:', error.message);
    isConnected = false;
  }
};

const connectConsumer = async () => {
  try {
    await consumer.connect();
    console.log('✅ Kafka Consumer connected');
  } catch (error) {
    console.error('❌ Kafka Consumer connection failed:', error.message);
  }
};

// Create Topics
const createTopics = async () => {
  try {
    await admin.connect();
    
    const existingTopics = await admin.listTopics();
    const topicsToCreate = Object.values(TOPICS)
      .filter(topic => !existingTopics.includes(topic))
      .map(topic => ({
        topic,
        numPartitions: 3,
        replicationFactor: 1,
        configEntries: [
          { name: 'retention.ms', value: '604800000' }, // 7 days
          { name: 'compression.type', value: 'snappy' },
        ],
      }));

    if (topicsToCreate.length > 0) {
      await admin.createTopics({
        topics: topicsToCreate,
        waitForLeaders: true,
      });
      console.log('✅ Kafka topics created:', topicsToCreate.map(t => t.topic).join(', '));
    }

    await admin.disconnect();
  } catch (error) {
    console.error('❌ Failed to create Kafka topics:', error.message);
  }
};

// Publish Event
const publishEvent = async (topic, event) => {
  if (!isConnected) {
    console.warn('⚠️  Kafka not connected, skipping event:', topic);
    return false;
  }

  try {
    await producer.send({
      topic,
      messages: [
        {
          key: event.key || event.userId || event.id,
          value: JSON.stringify(event),
          timestamp: Date.now().toString(),
        },
      ],
    });
    return true;
  } catch (error) {
    console.error(`❌ Failed to publish to ${topic}:`, error.message);
    return false;
  }
};

// Batch Publish
const publishBatch = async (topic, events) => {
  if (!isConnected) {
    console.warn('⚠️  Kafka not connected, skipping batch:', topic);
    return false;
  }

  try {
    await producer.send({
      topic,
      messages: events.map(event => ({
        key: event.key || event.userId || event.id,
        value: JSON.stringify(event),
        timestamp: Date.now().toString(),
      })),
    });
    return true;
  } catch (error) {
    console.error(`❌ Failed to publish batch to ${topic}:`, error.message);
    return false;
  }
};

// Subscribe to Topics
const subscribe = async (topics, handler) => {
  try {
    await consumer.subscribe({
      topics: Array.isArray(topics) ? topics : [topics],
      fromBeginning: false,
    });

    await consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const event = JSON.parse(message.value.toString());
          await handler(topic, event, { partition, offset: message.offset });
        } catch (error) {
          console.error(`❌ Error processing message from ${topic}:`, error);
        }
      },
    });
  } catch (error) {
    console.error('❌ Failed to subscribe to topics:', error.message);
  }
};

// Graceful Shutdown
const disconnect = async () => {
  try {
    await producer.disconnect();
    await consumer.disconnect();
    console.log('✅ Kafka disconnected gracefully');
  } catch (error) {
    console.error('❌ Error disconnecting Kafka:', error.message);
  }
};

module.exports = {
  kafka,
  producer,
  consumer,
  admin,
  TOPICS,
  connectProducer,
  connectConsumer,
  createTopics,
  publishEvent,
  publishBatch,
  subscribe,
  disconnect,
  isConnected: () => isConnected,
};
