# Real-time Notification System Setup Guide

## Overview
This guide explains how to set up and use the custom real-time notification system built with WebSockets (no Firebase required).

## Architecture

### Backend Components
1. **WebSocket Server** - Socket.io for real-time communication
2. **Notification Model** - MongoDB schema for storing notifications
3. **Notification Controller** - API endpoints for CRUD operations
4. **Notification Helper** - Utility functions for creating different notification types
5. **Push Notification Utils** - WebSocket-based notification delivery

### Frontend Components
1. **WebSocket Service** - Manages WebSocket connection and events
2. **Notification Service** - High-level notification management
3. **Notification Provider** - State management for notifications
4. **Notification Screen** - UI for displaying notifications
5. **Notification Badge** - Reusable badge widget for unread count

## Setup Instructions

### 1. Backend Setup

#### Install Dependencies
```bash
cd server
npm install socket.io
```

#### Environment Variables
Add to your `.env` file:
```env
# WebSocket Configuration
CLIENT_URL=http://localhost:3000
```

#### Start the Server
```bash
cd server
npm start
```
The server will start with WebSocket support on the same port.

### 2. Frontend Setup

#### Install Dependencies
```bash
cd apps
flutter pub add socket_io_client
flutter pub get
```

#### Initialize Notification Service
The notification service is automatically initialized in `main.dart` when the app starts.

### 3. Usage Examples

#### Using Notification Badge in Navigation
```dart
import 'package:flutter/material.dart';
import 'widgets/notification_badge.dart';

// In your navigation bar or app bar
NotificationIcon(
  size: 24,
  color: Colors.black,
  badgeColor: Colors.red,
)

// Or wrap any widget with a badge
NotificationBadge(
  child: Icon(Icons.notifications),
)
```

#### Creating Notifications from Backend
```javascript
const { createLikeNotification } = require('./utils/notificationHelper');

// When a user likes a post
await createLikeNotification(postId, likerId, postOwnerId);
```

#### Listening to Notifications in Flutter
```dart
// The NotificationProvider automatically handles this
Consumer<NotificationProvider>(
  builder: (context, provider, child) {
    return Text('Unread: ${provider.unreadCount}');
  },
)
```

## API Endpoints

### Get Notifications
```
GET /api/notifications?page=1&limit=20
Authorization: Bearer <token>
```

### Mark as Read
```
PUT /api/notifications/:id/read
Authorization: Bearer <token>
```

### Mark All as Read
```
PUT /api/notifications/mark-all-read
Authorization: Bearer <token>
```

### Delete Notification
```
DELETE /api/notifications/:id
Authorization: Bearer <token>
```

### Test Endpoints (Development Only)
```
POST /api/notifications/test/create    # Create test notifications
POST /api/notifications/test/like      # Create test like notification
POST /api/notifications/test/comment   # Create test comment notification
POST /api/notifications/test/follow    # Create test follow notification
```

## WebSocket Events

### Client → Server
- `getUnreadCount` - Request current unread count
- `notificationRead` - Mark notification as read
- `updateStatus` - Update user online status
- `typing` - Send typing indicator

### Server → Client
- `newNotification` - New notification received
- `unreadCountUpdate` - Unread count changed
- `userStatusUpdate` - User online/offline status
- `userTyping` - Typing indicator
- `systemNotification` - System-wide notifications

## Notification Types

1. **like** - Post liked
2. **comment** - Comment on post
3. **follow** - New follower
4. **mention** - User mentioned
5. **share** - Post shared
6. **achievement** - Achievement unlocked
7. **gift** - Gift received
8. **vote** - SYT entry voted
9. **system** - System notifications

## Testing the System

### 1. Start the Backend
```bash
cd server
npm start
```

### 2. Start the Flutter App
```bash
cd apps
flutter run
```

### 3. Test Real-time Notifications

#### Option A: Use Test API Endpoints
```bash
# Login first to get auth token
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"emailOrPhone": "your_email", "password": "your_password"}'

# Create test notifications
curl -X POST http://localhost:5000/api/notifications/test/create \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create specific notification types
curl -X POST http://localhost:5000/api/notifications/test/like \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Option B: Trigger from App Actions
- Like a post → Creates like notification
- Comment on post → Creates comment notification
- Follow user → Creates follow notification

### 4. Verify Real-time Delivery
1. Open the app and navigate to notifications screen
2. Trigger a notification (via API or app action)
3. You should see the notification appear instantly
4. The unread count badge should update in real-time

## Troubleshooting

### WebSocket Connection Issues
1. Check server is running on correct port
2. Verify CLIENT_URL in .env matches your app
3. Ensure user is logged in (token required)

### Notifications Not Appearing
1. Check WebSocket connection status
2. Verify notification creation in database
3. Check console logs for errors

### Badge Not Updating
1. Ensure NotificationProvider is properly initialized
2. Check if Consumer widgets are used correctly
3. Verify WebSocket events are being received

## Production Considerations

1. **Remove Test Routes** - Delete test endpoints from notification routes
2. **Rate Limiting** - Add rate limiting for notification creation
3. **Database Indexing** - Add indexes on notification queries
4. **Error Handling** - Implement proper error handling and retry logic
5. **Scaling** - Consider Redis for WebSocket scaling across multiple servers

## Security Features

1. **JWT Authentication** - All WebSocket connections require valid JWT
2. **User Isolation** - Users only receive their own notifications
3. **Input Validation** - All notification data is validated
4. **Rate Limiting** - Prevents notification spam

## Performance Optimizations

1. **Pagination** - Notifications are paginated for better performance
2. **Lazy Loading** - Load more notifications on scroll
3. **Connection Management** - Automatic reconnection on network issues
4. **Memory Management** - Proper cleanup of WebSocket connections

This notification system provides a complete, Firebase-free solution for real-time notifications in your ShowOff.life app!