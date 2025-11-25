const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Get messages between two users
// @route   GET /api/chat/:userId
// @access  Private
exports.getMessages = async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user.id;

    const messages = await Message.find({
      $or: [
        { sender: currentUserId, recipient: userId },
        { sender: userId, recipient: currentUserId },
      ],
    })
      .sort({ createdAt: 1 })
      .populate('sender', 'username displayName profilePicture')
      .populate('recipient', 'username displayName profilePicture')
      .limit(100);

    // Mark messages as read
    await Message.updateMany(
      { sender: userId, recipient: currentUserId, isRead: false },
      { isRead: true }
    );

    res.status(200).json({
      success: true,
      data: messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Send a message
// @route   POST /api/chat/:userId
// @access  Private
exports.sendMessage = async (req, res) => {
  try {
    const { userId } = req.params;
    const { text } = req.body;
    const currentUserId = req.user.id;

    if (!text || !text.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Message text is required',
      });
    }

    const message = await Message.create({
      sender: currentUserId,
      recipient: userId,
      text: text.trim(),
    });

    const populatedMessage = await Message.findById(message._id)
      .populate('sender', 'username displayName profilePicture')
      .populate('recipient', 'username displayName profilePicture');

    // Create message notification
    try {
      const { createMessageNotification } = require('../utils/notificationHelper');
      await createMessageNotification(currentUserId, userId, text.trim());
    } catch (notificationError) {
      console.error('❌ Error creating message notification:', notificationError);
    }

    res.status(201).json({
      success: true,
      data: populatedMessage,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get chat list (recent conversations)
// @route   GET /api/chat/conversations
// @access  Private
exports.getConversations = async (req, res) => {
  try {
    const mongoose = require('mongoose');
    const currentUserId = new mongoose.Types.ObjectId(req.user.id);

    // Get all unique users the current user has chatted with
    const messages = await Message.aggregate([
      {
        $match: {
          $or: [
            { sender: currentUserId },
            { recipient: currentUserId },
          ],
        },
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $group: {
          _id: {
            $cond: [
              { $eq: ['$sender', currentUserId] },
              '$recipient',
              '$sender',
            ],
          },
          lastMessage: { $first: '$$ROOT' },
          unreadCount: {
            $sum: {
              $cond: [
                {
                  $and: [
                    { $eq: ['$recipient', currentUserId] },
                    { $eq: ['$isRead', false] },
                  ],
                },
                1,
                0,
              ],
            },
          },
        },
      },
    ]);



    // Populate user details and format response
    const populatedMessages = await User.populate(messages, {
      path: '_id',
      select: 'username displayName profilePicture isVerified',
    });

    // Format conversations for frontend
    const conversations = populatedMessages.map(msg => ({
      otherUser: msg._id, // This contains the populated user data
      lastMessage: {
        content: msg.lastMessage.text,
        createdAt: msg.lastMessage.createdAt,
      },
      unreadCount: msg.unreadCount,
    }));



    res.status(200).json({
      success: true,
      data: conversations,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
