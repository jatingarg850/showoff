const Group = require('../models/Group');
const GroupMessage = require('../models/GroupMessage');
const User = require('../models/User');

// @desc    Create a new group
// @route   POST /api/groups
// @access  Private
exports.createGroup = async (req, res) => {
  try {
    const { name, description, category } = req.body;
    
    console.log('📝 Creating group with data:', { name, description, category });
    console.log('📁 Files received:', req.files);

    let bannerImage = null;
    let logoImage = null;

    // Handle uploaded files
    if (req.files) {
      if (req.files.banner && req.files.banner[0]) {
        const bannerFile = req.files.banner[0];
        if (process.env.WASABI_BUCKET_NAME && bannerFile.location) {
          // S3/Wasabi URL
          bannerImage = bannerFile.location;
        } else {
          // Local file path
          bannerImage = `/uploads/images/${bannerFile.filename}`;
        }
        console.log('🖼️ Banner image uploaded:', bannerImage);
      }

      if (req.files.logo && req.files.logo[0]) {
        const logoFile = req.files.logo[0];
        if (process.env.WASABI_BUCKET_NAME && logoFile.location) {
          // S3/Wasabi URL
          logoImage = logoFile.location;
        } else {
          // Local file path
          logoImage = `/uploads/images/${logoFile.filename}`;
        }
        console.log('🏷️ Logo image uploaded:', logoImage);
      }
    }

    const group = await Group.create({
      name,
      description,
      category,
      bannerImage,
      logoImage,
      creator: req.user.id,
      members: [req.user.id], // Creator is automatically a member
    });

    await group.populate('creator', 'username displayName profilePicture');

    console.log('✅ Group created successfully:', group._id);

    res.status(201).json({
      success: true,
      data: group,
    });
  } catch (error) {
    console.error('❌ Error creating group:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get all groups
// @route   GET /api/groups
// @access  Public
exports.getGroups = async (req, res) => {
  try {
    const { category, search } = req.query;
    
    let query = { isActive: true, isPublic: true };
    
    if (category) {
      query.category = category;
    }
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const groups = await Group.find(query)
      .populate('creator', 'username displayName profilePicture')
      .sort({ membersCount: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      data: groups,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get single group
// @route   GET /api/groups/:id
// @access  Public
exports.getGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('creator', 'username displayName profilePicture')
      .populate('members', 'username displayName profilePicture');

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    res.status(200).json({
      success: true,
      data: group,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Join a group
// @route   POST /api/groups/:id/join
// @access  Private
exports.joinGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    // Check if already a member
    if (group.members.includes(req.user.id)) {
      return res.status(400).json({
        success: false,
        message: 'Already a member of this group',
      });
    }

    group.members.push(req.user.id);
    await group.save();

    res.status(200).json({
      success: true,
      message: 'Successfully joined the group',
      data: group,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Leave a group
// @route   POST /api/groups/:id/leave
// @access  Private
exports.leaveGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    // Check if member
    if (!group.members.includes(req.user.id)) {
      return res.status(400).json({
        success: false,
        message: 'Not a member of this group',
      });
    }

    // Don't allow creator to leave
    if (group.creator.toString() === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'Creator cannot leave the group',
      });
    }

    group.members = group.members.filter(
      member => member.toString() !== req.user.id
    );
    await group.save();

    res.status(200).json({
      success: true,
      message: 'Successfully left the group',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Send message to group
// @route   POST /api/groups/:id/messages
// @access  Private
exports.sendMessage = async (req, res) => {
  try {
    const { text } = req.body;
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    // Check if member
    if (!group.members.includes(req.user.id)) {
      return res.status(403).json({
        success: false,
        message: 'Must be a member to send messages',
      });
    }

    const message = await GroupMessage.create({
      group: req.params.id,
      sender: req.user.id,
      text,
    });

    await message.populate('sender', 'username displayName profilePicture');

    res.status(201).json({
      success: true,
      data: message,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get group messages
// @route   GET /api/groups/:id/messages
// @access  Private
exports.getMessages = async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    // Check if member
    if (!group.members.includes(req.user.id)) {
      return res.status(403).json({
        success: false,
        message: 'Must be a member to view messages',
      });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;

    const messages = await GroupMessage.find({ group: req.params.id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('sender', 'username displayName profilePicture');

    const total = await GroupMessage.countDocuments({ group: req.params.id });

    res.status(200).json({
      success: true,
      data: messages.reverse(), // Reverse to show oldest first
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

// @desc    Get user's groups
// @route   GET /api/groups/my-groups
// @access  Private
exports.getMyGroups = async (req, res) => {
  try {
    const groups = await Group.find({
      members: req.user.id,
      isActive: true,
    })
      .populate('creator', 'username displayName profilePicture')
      .sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      data: groups,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check if user is member of group
// @route   GET /api/groups/:id/membership
// @access  Private
exports.checkMembership = async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }

    const isMember = group.members.includes(req.user.id);
    const isCreator = group.creator.toString() === req.user.id;

    res.status(200).json({
      success: true,
      data: {
        isMember,
        isCreator,
        membersCount: group.membersCount,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = exports;
