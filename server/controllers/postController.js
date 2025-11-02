const Post = require('../models/Post');
const User = require('../models/User');
const Like = require('../models/Like');
const Comment = require('../models/Comment');
const Bookmark = require('../models/Bookmark');
const Share = require('../models/Share');
const { checkUploadReward } = require('../utils/coinSystem');

// @desc    Create post
// @route   POST /api/posts
// @access  Private
exports.createPost = async (req, res) => {
  try {
    const { caption, hashtags, type } = req.body;

    // Handle both single file and multiple files (media + thumbnail)
    const mediaFile = req.files?.media?.[0] || req.file;
    const thumbnailFile = req.files?.thumbnail?.[0];

    if (!mediaFile) {
      return res.status(400).json({
        success: false,
        message: 'Please upload media file',
      });
    }

    // Handle both S3 (location/key) and local storage (path)
    let mediaUrl;
    if (mediaFile.key) {
      // S3/Wasabi - construct correct public URL
      const region = process.env.WASABI_REGION || 'ap-southeast-1';
      const bucketName = process.env.WASABI_BUCKET_NAME;
      // Use path-style URL that matches SSL certificate
      mediaUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${mediaFile.key}`;
    } else if (mediaFile.location) {
      // Fallback to location if provided
      mediaUrl = mediaFile.location;
    } else {
      // Local storage - construct relative path
      const folder = mediaFile.mimetype.startsWith('image/') ? 'images' : 'videos';
      mediaUrl = `/uploads/${folder}/${mediaFile.filename}`;
    }

    // Handle thumbnail URL if provided
    let thumbnailUrl = null;
    if (thumbnailFile) {
      if (thumbnailFile.key) {
        const region = process.env.WASABI_REGION || 'ap-southeast-1';
        const bucketName = process.env.WASABI_BUCKET_NAME;
        thumbnailUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${thumbnailFile.key}`;
      } else if (thumbnailFile.location) {
        thumbnailUrl = thumbnailFile.location;
      } else {
        thumbnailUrl = `/uploads/images/${thumbnailFile.filename}`;
      }
    }

    // Determine type from file
    const mediaType = mediaFile.mimetype.startsWith('image/') ? 'image' : 
                     mediaFile.mimetype.startsWith('video/') ? 'video' : 'reel';

    const post = await Post.create({
      user: req.user.id,
      type: type || mediaType,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      caption,
      hashtags: hashtags ? hashtags.split(',').map(tag => tag.trim()) : [],
    });

    // Update user post count
    await User.findByIdAndUpdate(req.user.id, {
      $inc: { postsCount: 1 },
    });

    // Check and award upload reward
    const rewardResult = await checkUploadReward(req.user.id);

    res.status(201).json({
      success: true,
      data: post,
      reward: rewardResult,
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get feed posts
// @route   GET /api/posts/feed
// @access  Private
exports.getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await Post.find({ isActive: true })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'username displayName profilePicture isVerified');

    const total = await Post.countDocuments({ isActive: true });

    res.status(200).json({
      success: true,
      data: posts,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user posts
// @route   GET /api/posts/user/:userId
// @access  Public
exports.getUserPosts = async (req, res) => {
  try {
    const posts = await Post.find({ 
      user: req.params.userId,
      isActive: true,
    })
      .sort({ createdAt: -1 })
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: posts,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Like/Unlike post
// @route   POST /api/posts/:id/like
// @access  Private
exports.toggleLike = async (req, res) => {
  try {
    console.log('Toggle like request:', { userId: req.user.id, postId: req.params.id });
    
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    const existingLike = await Like.findOne({
      user: req.user.id,
      post: post._id,
    });

    if (existingLike) {
      // Unlike
      console.log('Unliking post - current count:', post.likesCount);
      await existingLike.deleteOne();
      post.likesCount = Math.max(0, post.likesCount - 1);
      await post.save();

      console.log('Unlike successful, new count:', post.likesCount);
      res.status(200).json({
        success: true,
        liked: false,
        likesCount: post.likesCount,
      });
    } else {
      // Like
      console.log('Liking post - current count:', post.likesCount);
      await Like.create({
        user: req.user.id,
        post: post._id,
      });
      post.likesCount = (post.likesCount || 0) + 1;
      await post.save();

      // Verify the actual count from database
      const actualCount = await Like.countDocuments({ post: post._id });
      console.log('Like successful, saved count:', post.likesCount, 'actual DB count:', actualCount);
      
      // If there's a mismatch, fix it
      if (actualCount !== post.likesCount) {
        console.log('Count mismatch detected! Fixing...');
        post.likesCount = actualCount;
        await post.save();
      }

      // Create notification for post owner (if not liking own post)
      console.log('🔍 Checking notification eligibility:');
      console.log('  Post owner ID:', post.user.toString());
      console.log('  Liker ID:', req.user.id);
      console.log('  Same user?', post.user.toString() === req.user.id);
      
      if (post.user.toString() !== req.user.id) {
        try {
          console.log('✅ Creating like notification...');
          const { createLikeNotification } = require('../utils/notificationHelper');
          await createLikeNotification(post._id, req.user.id, post.user);
          console.log('✅ Like notification created successfully');
        } catch (notificationError) {
          console.error('❌ Error creating like notification:', notificationError);
        }
      } else {
        console.log('⚠️ Skipping notification - user liked own post');
      }

      res.status(200).json({
        success: true,
        liked: true,
        likesCount: post.likesCount,
      });
    }
  } catch (error) {
    console.error('Like toggle error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Add comment
// @route   POST /api/posts/:id/comment
// @access  Private
exports.addComment = async (req, res) => {
  try {
    const { text } = req.body;
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    const comment = await Comment.create({
      user: req.user.id,
      post: post._id,
      text,
    });

    post.commentsCount += 1;
    await post.save();

    await comment.populate('user', 'username displayName profilePicture isVerified');

    // Create notification for post owner (if not commenting on own post)
    console.log('🔍 Checking comment notification eligibility:');
    console.log('  Post owner ID:', post.user.toString());
    console.log('  Commenter ID:', req.user.id);
    console.log('  Same user?', post.user.toString() === req.user.id);
    
    if (post.user.toString() !== req.user.id) {
      try {
        console.log('✅ Creating comment notification...');
        const { createCommentNotification } = require('../utils/notificationHelper');
        await createCommentNotification(post._id, comment._id, req.user.id, post.user, text);
        console.log('✅ Comment notification created successfully');
      } catch (notificationError) {
        console.error('❌ Error creating comment notification:', notificationError);
      }
    } else {
      console.log('⚠️ Skipping notification - user commented on own post');
    }

    res.status(201).json({
      success: true,
      data: comment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get post comments
// @route   GET /api/posts/:id/comments
// @access  Public
exports.getComments = async (req, res) => {
  try {
    const comments = await Comment.find({ 
      post: req.params.id,
      isActive: true,
      parentComment: null,
    })
      .sort({ createdAt: -1 })
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: comments,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Increment view count
// @route   POST /api/posts/:id/view
// @access  Public
exports.incrementView = async (req, res) => {
  try {
    const post = await Post.findByIdAndUpdate(
      req.params.id,
      { $inc: { viewsCount: 1 } },
      { new: true }
    );

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Update user total views
    await User.findByIdAndUpdate(post.user, {
      $inc: { totalViews: 1 },
    });

    res.status(200).json({
      success: true,
      viewsCount: post.viewsCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Bookmark/Unbookmark post
// @route   POST /api/posts/:id/bookmark
// @access  Private
exports.toggleBookmark = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    const existingBookmark = await Bookmark.findOne({
      user: req.user.id,
      post: post._id,
    });

    if (existingBookmark) {
      // Remove bookmark
      await existingBookmark.deleteOne();

      res.status(200).json({
        success: true,
        bookmarked: false,
        message: 'Post removed from bookmarks',
      });
    } else {
      // Add bookmark
      await Bookmark.create({
        user: req.user.id,
        post: post._id,
      });

      res.status(200).json({
        success: true,
        bookmarked: true,
        message: 'Post bookmarked successfully',
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Share post
// @route   POST /api/posts/:id/share
// @access  Private
exports.sharePost = async (req, res) => {
  try {
    const { shareType = 'link' } = req.body;
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Create share record
    await Share.create({
      user: req.user.id,
      post: post._id,
      shareType,
    });

    // Increment share count
    post.sharesCount += 1;
    await post.save();

    res.status(200).json({
      success: true,
      sharesCount: post.sharesCount,
      message: 'Post shared successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user bookmarks
// @route   GET /api/posts/bookmarks
// @access  Private
exports.getUserBookmarks = async (req, res) => {
  try {
    const bookmarks = await Bookmark.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .populate({
        path: 'post',
        populate: {
          path: 'user',
          select: 'username displayName profilePicture isVerified',
        },
      });

    const posts = bookmarks.map(bookmark => bookmark.post).filter(post => post && post.isActive);

    res.status(200).json({
      success: true,
      data: posts,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get post engagement stats
// @route   GET /api/posts/:id/stats
// @access  Public
exports.getPostStats = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Get bookmark count for this post
    const bookmarksCount = await Bookmark.countDocuments({ post: post._id });

    // Check if current user has liked/bookmarked
    const like = await Like.findOne({ user: req.user.id, post: post._id });
    const bookmark = await Bookmark.findOne({ user: req.user.id, post: post._id });
    const isLiked = !!like;
    const isBookmarked = !!bookmark;

    console.log('Get stats:', { postId: post._id, userId: req.user.id, isLiked, likesCount: post.likesCount });

    res.status(200).json({
      success: true,
      data: {
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
        sharesCount: post.sharesCount,
        viewsCount: post.viewsCount,
        bookmarksCount,
        isLiked,
        isBookmarked,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
