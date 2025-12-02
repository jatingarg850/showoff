# 🚀 Apache Kafka Implementation Guide

## Overview

ShowOff.life now uses Apache Kafka for enterprise-grade event-driven architecture, enabling:
- **Scalability**: Handle millions of events per second
- **Reliability**: Guaranteed message delivery with fault tolerance
- **Decoupling**: Microservices can operate independently
- **Real-time Processing**: Instant event processing and notifications
- **Analytics**: Stream processing for real-time insights

## Architecture

```
┌─────────────┐     ┌──────────┐     ┌─────────────┐
│   Client    │────▶│  Server  │────▶│   Kafka     │
│   (App)     │     │  (API)   │     │  (Broker)   │
└─────────────┘     └──────────┘     └─────────────┘
                          │                  │
                          │                  ▼
                          │           ┌─────────────┐
                          │           │  Consumers  │
                          │           │  (Workers)  │
                          │           └─────────────┘
                          │                  │
                          ▼                  ▼
                    ┌──────────────────────────┐
                    │   Database / Services    │
                    └──────────────────────────┘
```

## Topics

### 1. **user-events**
- User registration
- User login
- Profile updates
- Account changes

### 2. **notification-events**
- Push notifications
- In-app notifications
- Email notifications
- SMS notifications

### 3. **post-events**
- Post creation
- Post likes
- Post comments
- Post views

### 4. **transaction-events**
- Coin transactions
- Purchases
- Withdrawals
- Rewards

### 5. **video-processing**
- Video uploads
- Transcoding
- Thumbnail generation
- Quality optimization

### 6. **analytics-events**
- User behavior
- Engagement metrics
- Performance data
- Business intelligence

### 7. **email-events**
- Welcome emails
- Notifications
- Marketing campaigns
- Transactional emails

### 8. **sms-events**
- OTP messages
- Alerts
- Notifications

## Installation

### Option 1: Docker (Recommended)

```bash
# Start Kafka cluster
cd server
docker-compose -f docker-compose.kafka.yml up -d

# Check status
docker-compose -f docker-compose.kafka.yml ps

# View logs
docker-compose -f docker-compose.kafka.yml logs -f kafka

# Access Kafka UI
# Open http://localhost:8080 in browser
```

### Option 2: Manual Installation

#### Windows:
1. Download Kafka from https://kafka.apache.org/downloads
2. Extract to `C:\kafka`
3. Start Zookeeper:
   ```cmd
   cd C:\kafka
   bin\windows\zookeeper-server-start.bat config\zookeeper.properties
   ```
4. Start Kafka (new terminal):
   ```cmd
   cd C:\kafka
   bin\windows\kafka-server-start.bat config\server.properties
   ```

#### Linux/Mac:
```bash
# Download and extract
wget https://downloads.apache.org/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
cd kafka_2.13-3.6.0

# Start Zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties &

# Start Kafka
bin/kafka-server-start.sh config/server.properties &
```

## Configuration

### Environment Variables

Add to `server/.env`:

```env
# Kafka Configuration
KAFKA_ENABLED=true
KAFKA_BROKERS=localhost:9092
KAFKA_CONSUMER_GROUP=showoff-life-consumer-group

# For production with multiple brokers
# KAFKA_BROKERS=broker1:9092,broker2:9092,broker3:9092
```

### Server Integration

The Kafka integration is automatically initialized in `server.js`:

```javascript
const { connectProducer, connectConsumer, createTopics } = require('./config/kafka');
const KafkaConsumerService = require('./services/kafkaConsumerService');

// Initialize Kafka
if (process.env.KAFKA_ENABLED === 'true') {
  connectProducer();
  connectConsumer();
  createTopics();
  KafkaConsumerService.startConsumers();
}
```

## Usage Examples

### Publishing Events

```javascript
const KafkaProducerService = require('./services/kafkaProducerService');

// User registration
await KafkaProducerService.publishUserRegistered(user);

// Post creation
await KafkaProducerService.publishPostCreated(post);

// Notification
await KafkaProducerService.publishNotification(notification);

// Transaction
await KafkaProducerService.publishTransaction(transaction);

// Bulk notifications
await KafkaProducerService.publishBulkNotifications(notifications);
```

### Consuming Events

Events are automatically consumed by `KafkaConsumerService`. Add custom handlers in:
`server/services/kafkaConsumerService.js`

## Monitoring

### Kafka UI (Docker)
Access at: http://localhost:8080

Features:
- View topics and messages
- Monitor consumer groups
- Check broker health
- Manage configurations

### Command Line Tools

```bash
# List topics
docker exec showoff-kafka kafka-topics --list --bootstrap-server localhost:9092

# Describe topic
docker exec showoff-kafka kafka-topics --describe --topic user-events --bootstrap-server localhost:9092

# View messages
docker exec showoff-kafka kafka-console-consumer --topic user-events --from-beginning --bootstrap-server localhost:9092

# Check consumer groups
docker exec showoff-kafka kafka-consumer-groups --list --bootstrap-server localhost:9092

# Consumer group details
docker exec showoff-kafka kafka-consumer-groups --describe --group showoff-life-consumer-group --bootstrap-server localhost:9092
```

## Production Deployment

### 1. Cloud Kafka Services (Recommended)

#### Confluent Cloud
- Fully managed Kafka
- Auto-scaling
- Global availability
- https://confluent.cloud

#### AWS MSK (Managed Streaming for Kafka)
- Integrated with AWS services
- Automatic patching
- Built-in monitoring

#### Azure Event Hubs
- Kafka-compatible
- Enterprise-grade security
- Global distribution

### 2. Self-Hosted Production Setup

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  zookeeper-1:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_SERVER_ID: 1
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_SERVERS: zookeeper-1:2888:3888;zookeeper-2:2888:3888;zookeeper-3:2888:3888

  kafka-1:
    image: confluentinc/cp-kafka:latest
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-1:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 3
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 2
      KAFKA_MIN_INSYNC_REPLICAS: 2
```

### 3. Environment Configuration

```env
# Production
KAFKA_ENABLED=true
KAFKA_BROKERS=kafka-1:9092,kafka-2:9092,kafka-3:9092
KAFKA_CONSUMER_GROUP=showoff-life-prod-consumer-group
```

## Performance Tuning

### Producer Configuration

```javascript
// config/kafka.js
const producer = kafka.producer({
  allowAutoTopicCreation: true,
  transactionTimeout: 30000,
  compression: 'snappy', // or 'gzip', 'lz4'
  idempotent: true,
  maxInFlightRequests: 5,
  retry: {
    initialRetryTime: 100,
    retries: 8,
  },
});
```

### Consumer Configuration

```javascript
const consumer = kafka.consumer({
  groupId: 'showoff-life-consumer-group',
  sessionTimeout: 30000,
  heartbeatInterval: 3000,
  maxBytesPerPartition: 1048576,
  minBytes: 1,
  maxBytes: 10485760,
  maxWaitTimeInMs: 5000,
});
```

## Troubleshooting

### Kafka Not Connecting

```bash
# Check if Kafka is running
docker ps | grep kafka

# Check Kafka logs
docker logs showoff-kafka

# Test connection
telnet localhost 9092
```

### Messages Not Being Consumed

```bash
# Check consumer group lag
docker exec showoff-kafka kafka-consumer-groups --describe --group showoff-life-consumer-group --bootstrap-server localhost:9092

# Reset consumer offset (if needed)
docker exec showoff-kafka kafka-consumer-groups --reset-offsets --group showoff-life-consumer-group --topic user-events --to-earliest --execute --bootstrap-server localhost:9092
```

### High Latency

1. Increase partitions:
   ```bash
   docker exec showoff-kafka kafka-topics --alter --topic user-events --partitions 6 --bootstrap-server localhost:9092
   ```

2. Add more consumers (scale horizontally)

3. Tune batch settings

## Best Practices

1. **Topic Naming**: Use descriptive, hierarchical names
2. **Partitioning**: More partitions = more parallelism
3. **Replication**: Use replication factor of 3 in production
4. **Monitoring**: Always monitor lag and throughput
5. **Error Handling**: Implement dead letter queues
6. **Schema Management**: Use Avro or Protobuf for schemas
7. **Security**: Enable SSL/TLS and SASL authentication
8. **Backup**: Regular backups of Zookeeper data

## Cost Estimation

### Self-Hosted (AWS EC2)
- 3 Kafka brokers (t3.large): ~$150/month
- 3 Zookeeper nodes (t3.small): ~$50/month
- Storage (EBS): ~$50/month
- **Total**: ~$250/month

### Managed Services
- Confluent Cloud: $100-500/month (based on usage)
- AWS MSK: $200-600/month
- Azure Event Hubs: $150-400/month

## Migration Strategy

1. **Phase 1**: Run Kafka alongside existing system
2. **Phase 2**: Gradually move events to Kafka
3. **Phase 3**: Monitor and optimize
4. **Phase 4**: Fully migrate and remove old system

## Support

- Kafka Documentation: https://kafka.apache.org/documentation/
- KafkaJS Documentation: https://kafka.js.org/
- Community: https://kafka.apache.org/community

---

**Status**: ✅ Kafka implementation complete and ready for production!
