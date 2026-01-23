const http = require('http');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');

// Configuration
const BASE_URL = 'http://localhost:5000';
let sessionCookie = '';

// Helper function to make HTTP requests
function makeRequest(method, pathname, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(pathname, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    };

    if (sessionCookie) {
      options.headers['Cookie'] = sessionCookie;
    }

    const req = http.request(options, (res) => {
      let data = '';
      
      // Capture Set-Cookie header for session management
      if (res.headers['set-cookie']) {
        sessionCookie = res.headers['set-cookie'][0].split(';')[0];
        console.log('📝 Session cookie updated');
      }

      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: JSON.parse(data),
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: data,
          });
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

// Helper function to make multipart form requests
function makeFormRequest(method, pathname, formData) {
  return new Promise((resolve, reject) => {
    const url = new URL(pathname, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: formData.getHeaders(),
    };

    if (sessionCookie) {
      options.headers['Cookie'] = sessionCookie;
    }

    const req = http.request(options, (res) => {
      let data = '';
      
      // Capture Set-Cookie header for session management
      if (res.headers['set-cookie']) {
        sessionCookie = res.headers['set-cookie'][0].split(';')[0];
        console.log('📝 Session cookie updated');
      }

      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: JSON.parse(data),
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: data,
          });
        }
      });
    });

    req.on('error', reject);
    formData.pipe(req);
  });
}

async function testVideoAdUpload() {
  console.log('🎬 Testing Video Ad Upload\n');

  try {
    // Step 1: Login
    console.log('📝 Step 1: Logging in as admin...');
    const loginRes = await makeRequest('POST', '/admin/login', {
      email: 'admin@showofflife.com',
      password: 'admin123',
    });

    if (loginRes.status !== 302 && loginRes.status !== 200) {
      console.log('❌ Login failed:', loginRes.status);
      console.log('Response:', loginRes.data);
      return;
    }

    console.log('✅ Login successful');
    console.log('   Session:', sessionCookie.substring(0, 30) + '...');

    // Step 2: Create test files
    console.log('\n📁 Step 2: Creating test files...');
    
    // Create a simple test video file (just a small binary file)
    const testVideoPath = path.join(__dirname, 'test_video.mp4');
    const testThumbnailPath = path.join(__dirname, 'test_thumbnail.png');
    
    // Create minimal MP4 file (just for testing)
    const mp4Header = Buffer.from([
      0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70,
      0x69, 0x73, 0x6f, 0x6d, 0x00, 0x00, 0x00, 0x00,
      0x69, 0x73, 0x6f, 0x6d, 0x69, 0x73, 0x6f, 0x32,
      0x6d, 0x70, 0x34, 0x31, 0x00, 0x00, 0x00, 0x00,
    ]);
    fs.writeFileSync(testVideoPath, mp4Header);
    console.log('✅ Test video file created:', testVideoPath);
    
    // Create minimal PNG file
    const pngHeader = Buffer.from([
      0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
      0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
      0xde, 0x00, 0x00, 0x00, 0x0c, 0x49, 0x44, 0x41,
      0x54, 0x08, 0x99, 0x63, 0xf8, 0xcf, 0xc0, 0x00,
      0x00, 0x00, 0x03, 0x00, 0x01, 0x4b, 0x6e, 0x0e,
      0x56, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e,
      0x44, 0xae, 0x42, 0x60, 0x82,
    ]);
    fs.writeFileSync(testThumbnailPath, pngHeader);
    console.log('✅ Test thumbnail file created:', testThumbnailPath);

    // Step 3: Upload video ad
    console.log('\n📤 Step 3: Uploading video ad...');
    
    const form = new FormData();
    form.append('title', 'Test Video Ad');
    form.append('description', 'This is a test video ad');
    form.append('duration', '30');
    form.append('rewardCoins', '10');
    form.append('icon', 'video');
    form.append('color', '#667eea');
    form.append('rotationOrder', '0');
    form.append('isActive', 'true');
    form.append('video', fs.createReadStream(testVideoPath), 'test_video.mp4');
    form.append('thumbnail', fs.createReadStream(testThumbnailPath), 'test_thumbnail.png');

    const uploadRes = await makeFormRequest('POST', '/admin/video-ads/create', form);
    
    console.log('   Status:', uploadRes.status);
    console.log('   Response:', JSON.stringify(uploadRes.data, null, 2));

    if (uploadRes.status === 200 && uploadRes.data.success) {
      console.log('✅ Video ad uploaded successfully');
      console.log('   Video Ad ID:', uploadRes.data.data._id);
      console.log('   Title:', uploadRes.data.data.title);
      console.log('   Video URL:', uploadRes.data.data.videoUrl);
      console.log('   Thumbnail URL:', uploadRes.data.data.thumbnailUrl);
      console.log('   Uploaded By:', uploadRes.data.data.uploadedBy);
    } else {
      console.log('❌ Video ad upload failed');
      return;
    }

    // Step 4: Verify video ad in list
    console.log('\n📋 Step 4: Verifying video ad in list...');
    const listRes = await makeRequest('GET', '/admin/video-ads');
    
    if (listRes.status === 200) {
      console.log('✅ Video ads list retrieved');
      console.log('   Total ads:', listRes.data.data?.length || 0);
      
      const testAd = listRes.data.data?.find(ad => ad.title === 'Test Video Ad');
      if (testAd) {
        console.log('✅ Test video ad found in list');
        console.log('   ID:', testAd._id);
        console.log('   Status:', testAd.isActive ? 'Active' : 'Inactive');
      } else {
        console.log('⚠️  Test video ad not found in list');
      }
    }

    // Step 5: Cleanup
    console.log('\n🧹 Step 5: Cleaning up test files...');
    fs.unlinkSync(testVideoPath);
    fs.unlinkSync(testThumbnailPath);
    console.log('✅ Test files deleted');

    console.log('\n✅ Video ad upload test completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run the test
testVideoAdUpload();
