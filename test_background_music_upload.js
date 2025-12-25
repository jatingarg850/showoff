const http = require('http');
const https = require('https');

// Configuration
const API_BASE = 'http://localhost:3000/api';
let authToken = null;
let userId = null;
let musicId = null;
let postId = null;

// Helper function to make HTTP requests
function makeRequest(method, path, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_BASE + path);
    const isHttps = url.protocol === 'https:';
    const client = isHttps ? https : http;

    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    };

    if (authToken) {
      options.headers['Authorization'] = `Bearer ${authToken}`;
    }

    const req = client.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Background Music Upload Test Suite\n');

  try {
    // Step 1: Register/Login
    console.log('📝 Step 1: Registering test user...');
    const registerRes = await makeRequest('POST', '/auth/register', {
      username: `testuser_${Date.now()}`,
      displayName: 'Test User',
      password: 'Test@123456',
      email: `test_${Date.now()}@example.com`,
      termsAccepted: true,
    });

    if (!registerRes.data.success) {
      throw new Error(`Registration failed: ${registerRes.data.message}`);
    }

    console.log('Register response:', JSON.stringify(registerRes.data, null, 2));

    authToken = registerRes.data.data.token;
    userId = registerRes.data.data.user.id || registerRes.data.data.user._id;
    console.log(`✅ User registered: ${userId}`);
    console.log(`✅ Auth token: ${authToken.substring(0, 20)}...`);

    // Step 2: Get approved music
    console.log('\n📝 Step 2: Fetching approved music...');
    const musicRes = await makeRequest('GET', '/music/approved?limit=1');

    console.log('Music response:', JSON.stringify(musicRes, null, 2));

    if (!musicRes.data.success || musicRes.data.data.length === 0) {
      throw new Error('No approved music found. Please upload and approve music first.');
    }

    musicId = musicRes.data.data[0]._id;
    console.log(`✅ Found music: ${musicRes.data.data[0].title}`);
    console.log(`✅ Music ID: ${musicId}`);

    // Step 3: Create post with background music
    console.log('\n📝 Step 3: Creating post with background music...');
    const createPostRes = await makeRequest('POST', '/posts/create-with-url', {
      mediaUrl: 'https://via.placeholder.com/640x480.jpg',
      mediaType: 'image',
      caption: 'Test post with background music',
      musicId: musicId,
      isPublic: true,
    });

    if (!createPostRes.data.success) {
      throw new Error(`Post creation failed: ${createPostRes.data.message}`);
    }

    postId = createPostRes.data.data._id;
    console.log(`✅ Post created: ${postId}`);
    console.log(`✅ Post backgroundMusic field: ${createPostRes.data.data.backgroundMusic}`);

    // Step 4: Fetch feed to verify music is populated
    console.log('\n📝 Step 4: Fetching feed to verify music is populated...');
    const feedRes = await makeRequest('GET', '/posts/feed?page=1&limit=10');

    if (!feedRes.data.success) {
      throw new Error(`Feed fetch failed: ${feedRes.data.message}`);
    }

    const post = feedRes.data.data.find((p) => p._id === postId);
    if (!post) {
      throw new Error('Post not found in feed');
    }

    console.log(`✅ Post found in feed`);
    console.log(`✅ Post backgroundMusic: ${JSON.stringify(post.backgroundMusic, null, 2)}`);

    if (!post.backgroundMusic) {
      console.log('❌ ERROR: backgroundMusic is null or undefined!');
      console.log('   This means the music was not saved with the post.');
    } else if (typeof post.backgroundMusic === 'string') {
      console.log('⚠️  WARNING: backgroundMusic is a string (ID only), not populated');
      console.log(`   Music ID: ${post.backgroundMusic}`);
    } else if (typeof post.backgroundMusic === 'object') {
      console.log('✅ SUCCESS: backgroundMusic is populated with full object');
      console.log(`   Music Title: ${post.backgroundMusic.title}`);
      console.log(`   Music Artist: ${post.backgroundMusic.artist}`);
      console.log(`   Audio URL: ${post.backgroundMusic.audioUrl}`);
    }

    // Step 5: Get user posts to verify
    console.log('\n📝 Step 5: Fetching user posts...');
    const userPostsRes = await makeRequest('GET', `/posts/user/${userId}`);

    if (!userPostsRes.data.success) {
      throw new Error(`User posts fetch failed: ${userPostsRes.data.message}`);
    }

    const userPost = userPostsRes.data.data.find((p) => p._id === postId);
    if (!userPost) {
      throw new Error('Post not found in user posts');
    }

    console.log(`✅ Post found in user posts`);
    console.log(`✅ Post backgroundMusic: ${JSON.stringify(userPost.backgroundMusic, null, 2)}`);

    // Summary
    console.log('\n📊 Test Summary:');
    console.log(`✅ User ID: ${userId}`);
    console.log(`✅ Music ID: ${musicId}`);
    console.log(`✅ Post ID: ${postId}`);
    console.log(`✅ Post backgroundMusic in feed: ${post.backgroundMusic ? 'YES' : 'NO'}`);
    console.log(`✅ Post backgroundMusic in user posts: ${userPost.backgroundMusic ? 'YES' : 'NO'}`);

    if (post.backgroundMusic && userPost.backgroundMusic) {
      console.log('\n✅ SUCCESS: Background music is being saved and retrieved correctly!');
    } else {
      console.log('\n❌ FAILURE: Background music is not being saved or retrieved!');
    }
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runTests();
