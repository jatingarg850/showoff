const Music = require('../models/Music');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

// Configure multer for music uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/music');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'music-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    // Accept only audio files
    const allowedMimes = ['audio/mpeg', 'audio/wav', 'audio/mp4', 'audio/aac', 'audio/ogg'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only audio files are allowed'));
    }
  },
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit
  }
});

// Get all music
exports.getAllMusic = async (req, res) => {
  try {
    const { page = 1, limit = 10, isApproved, isActive, genre, mood } = req.query;
    
    const filter = {};
    
    // Handle isApproved filter - can be 'true', 'false', or undefined
    if (isApproved !== undefined && isApproved !== '') {
      filter.isApproved = isApproved === 'true' || isApproved === true;
    }
    
    // Handle isActive filter
    if (isActive !== undefined && isActive !== '') {
      filter.isActive = isActive === 'true' || isActive === true;
    }
    
    // Handle genre filter
    if (genre && genre !== '') {
      filter.genre = genre;
    }
    
    // Handle mood filter
    if (mood && mood !== '') {
      filter.mood = mood;
    }

    const skip = (page - 1) * limit;
    
    console.log('🔍 Music Query Filter:', filter);
    
    const music = await Music.find(filter)
      .populate('uploadedBy', 'username displayName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Music.countDocuments(filter);

    console.log(`✅ Found ${music.length} music items (Total: ${total})`);

    res.json({
      success: true,
      data: music,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching music:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching music',
      error: error.message
    });
  }
};

// Get approved music (for users)
exports.getApprovedMusic = async (req, res) => {
  try {
    const { page = 1, limit = 50, genre, mood } = req.query;
    
    const filter = {
      isApproved: true,
      isActive: true
    };
    
    if (genre && genre !== '') filter.genre = genre;
    if (mood && mood !== '') filter.mood = mood;

    const skip = (page - 1) * limit;
    
    const music = await Music.find(filter)
      .populate('uploadedBy', 'username displayName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Music.countDocuments(filter);

    res.json({
      success: true,
      data: music,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching approved music:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching approved music',
      error: error.message
    });
  }
};

// Get single music
exports.getMusic = async (req, res) => {
  try {
    const music = await Music.findById(req.params.id)
      .populate('uploadedBy', 'username displayName');

    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }

    res.json({
      success: true,
      data: music
    });
  } catch (error) {
    console.error('Error fetching music:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching music',
      error: error.message
    });
  }
};

// Upload music
exports.uploadMusic = async (req, res) => {
  try {
    console.log('📤 Music Upload Request');
    console.log('  - File:', req.file?.filename);
    console.log('  - Body:', req.body);
    
    if (!req.file) {
      console.error('❌ No audio file provided');
      return res.status(400).json({
        success: false,
        message: 'No audio file provided'
      });
    }

    const { title, artist, genre, mood, duration } = req.body;

    if (!title || !artist) {
      // Delete uploaded file if validation fails
      fs.unlinkSync(req.file.path);
      console.error('❌ Title and artist are required');
      return res.status(400).json({
        success: false,
        message: 'Title and artist are required'
      });
    }

    const audioUrl = `/uploads/music/${req.file.filename}`;

    const music = new Music({
      title: title.trim(),
      artist: artist.trim(),
      audioUrl,
      duration: parseInt(duration) || 0,
      genre: genre || 'other',
      mood: mood || 'other',
      uploadedBy: req.user?.id || null,
      isApproved: false,
      isActive: true
    });

    const savedMusic = await music.save();
    
    console.log('✅ Music saved successfully');
    console.log('  - ID:', savedMusic._id);
    console.log('  - Title:', savedMusic.title);
    console.log('  - URL:', savedMusic.audioUrl);

    res.status(201).json({
      success: true,
      message: 'Music uploaded successfully',
      data: savedMusic
    });
  } catch (error) {
    // Delete uploaded file if error occurs
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (e) {
        console.error('Error deleting file:', e);
      }
    }
    console.error('❌ Error uploading music:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading music',
      error: error.message
    });
  }
};

// Update music
exports.updateMusic = async (req, res) => {
  try {
    const { title, artist, genre, mood, duration, isApproved, isActive } = req.body;

    const music = await Music.findById(req.params.id);

    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }

    // Update fields
    if (title) music.title = title;
    if (artist) music.artist = artist;
    if (genre) music.genre = genre;
    if (mood) music.mood = mood;
    if (duration) music.duration = parseInt(duration);
    if (isApproved !== undefined) music.isApproved = isApproved;
    if (isActive !== undefined) music.isActive = isActive;

    await music.save();

    res.json({
      success: true,
      message: 'Music updated successfully',
      data: music
    });
  } catch (error) {
    console.error('Error updating music:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating music',
      error: error.message
    });
  }
};

// Delete music
exports.deleteMusic = async (req, res) => {
  try {
    const music = await Music.findById(req.params.id);

    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }

    // Delete audio file
    const audioPath = path.join(__dirname, '../public', music.audioUrl);
    if (fs.existsSync(audioPath)) {
      fs.unlinkSync(audioPath);
    }

    await Music.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Music deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting music:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting music',
      error: error.message
    });
  }
};

// Approve music
exports.approveMusic = async (req, res) => {
  try {
    const music = await Music.findByIdAndUpdate(
      req.params.id,
      { isApproved: true },
      { new: true }
    );

    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }

    res.json({
      success: true,
      message: 'Music approved successfully',
      data: music
    });
  } catch (error) {
    console.error('Error approving music:', error);
    res.status(500).json({
      success: false,
      message: 'Error approving music',
      error: error.message
    });
  }
};

// Reject music
exports.rejectMusic = async (req, res) => {
  try {
    const music = await Music.findById(req.params.id);

    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }

    // Delete audio file
    const audioPath = path.join(__dirname, '../public', music.audioUrl);
    if (fs.existsSync(audioPath)) {
      fs.unlinkSync(audioPath);
    }

    await Music.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Music rejected and deleted successfully'
    });
  } catch (error) {
    console.error('Error rejecting music:', error);
    res.status(500).json({
      success: false,
      message: 'Error rejecting music',
      error: error.message
    });
  }
};

// Search music
exports.searchMusic = async (req, res) => {
  try {
    const { q, page = 1, limit = 50, genre, mood } = req.query;

    if (!q || q.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const filter = {
      isApproved: true,
      isActive: true,
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { artist: { $regex: q, $options: 'i' } }
      ]
    };

    if (genre && genre !== '') filter.genre = genre;
    if (mood && mood !== '') filter.mood = mood;

    const skip = (page - 1) * limit;

    const music = await Music.find(filter)
      .populate('uploadedBy', 'username displayName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Music.countDocuments(filter);

    res.json({
      success: true,
      data: music,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error searching music:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching music',
      error: error.message
    });
  }
};

// Get music statistics
exports.getMusicStats = async (req, res) => {
  try {
    const total = await Music.countDocuments();
    const approved = await Music.countDocuments({ isApproved: true });
    const pending = await Music.countDocuments({ isApproved: false });
    const active = await Music.countDocuments({ isActive: true });

    const genreStats = await Music.aggregate([
      { $group: { _id: '$genre', count: { $sum: 1 } } }
    ]);

    const moodStats = await Music.aggregate([
      { $group: { _id: '$mood', count: { $sum: 1 } } }
    ]);

    res.json({
      success: true,
      data: {
        total,
        approved,
        pending,
        active,
        genreStats,
        moodStats
      }
    });
  } catch (error) {
    console.error('Error fetching music stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching music stats',
      error: error.message
    });
  }
};

module.exports = {
  upload,
  getAllMusic: exports.getAllMusic,
  getApprovedMusic: exports.getApprovedMusic,
  getMusic: exports.getMusic,
  searchMusic: exports.searchMusic,
  uploadMusic: exports.uploadMusic,
  updateMusic: exports.updateMusic,
  deleteMusic: exports.deleteMusic,
  approveMusic: exports.approveMusic,
  rejectMusic: exports.rejectMusic,
  getMusicStats: exports.getMusicStats
};
