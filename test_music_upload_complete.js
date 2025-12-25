const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:3000';

// Create a dummy audio file for testing
const createDummyAudioFile = () => {
  const audioPath = path.join(__dirname, 'test-audio.mp3');
  // Create a minimal MP3 file (just headers, not a real audio)
  const mp3Header = Buffer.from([
    0xFF, 0xFB, 0x90, 0x00, // MP3 sync word and header
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  ]);
  fs.writeFileSync(audioPath, mp3Header);
  return audioPath;
};

const testMusicUpload = async () => {
  try {
    console.log('🎵 Testing Music Upload System\n');
    
    // Create dummy audio file
    const audioPath = createDummyAudioFile();
    console.log('✅ Created test audio file:', audioPath);
    
    // Test 1: Upload music
    console.log('\n📤 Test 1: Uploading music...');
    const form = new FormData();
    form.append('audio', fs.createReadStream(audioPath));
    form.append('title', 'Test Song ' + Date.now());
    form.append('artist', 'Test Artist');
    form.append('genre', 'pop');
    form.append('mood', 'happy');
    form.append('duration', '180');
    
    const uploadResponse = await fetch(`${BASE_URL}/admin/music/upload`, {
      method: 'POST',
      body: form,
      headers: form.getHeaders(),
      credentials: 'include'
    });
    
    const uploadData = await uploadResponse.json();
    console.log('Response Status:', uploadResponse.status);
    console.log('Response:', JSON.stringify(uploadData, null, 2));
    
    if (!uploadData.success) {
      console.error('❌ Upload failed');
      return;
    }
    
    const musicId = uploadData.data._id;
    console.log('✅ Music uploaded successfully! ID:', musicId);
    
    // Test 2: Get all music
    console.log('\n📋 Test 2: Fetching all music...');
    const allMusicResponse = await fetch(`${BASE_URL}/admin/music?page=1&limit=10`, {
      credentials: 'include'
    });
    const allMusicData = await allMusicResponse.json();
    console.log('Total music items:', allMusicData.pagination.total);
    console.log('Music in response:', allMusicData.data.length);
    
    if (allMusicData.data.length > 0) {
      console.log('✅ Music list retrieved successfully');
      console.log('First item:', {
        id: allMusicData.data[0]._id,
        title: allMusicData.data[0].title,
        artist: allMusicData.data[0].artist,
        isApproved: allMusicData.data[0].isApproved
      });
    } else {
      console.error('❌ No music found in list');
    }
    
    // Test 3: Get approved music (for app)
    console.log('\n🎵 Test 3: Fetching approved music (for app)...');
    const approvedResponse = await fetch(`${BASE_URL}/api/music/approved?page=1&limit=50`);
    const approvedData = await approvedResponse.json();
    console.log('Approved music count:', approvedData.data.length);
    
    // Test 4: Approve the uploaded music
    console.log('\n✅ Test 4: Approving music...');
    const approveResponse = await fetch(`${BASE_URL}/admin/music/${musicId}/approve`, {
      method: 'POST',
      credentials: 'include'
    });
    const approveData = await approveResponse.json();
    console.log('Approve Response:', approveData.success ? '✅ Success' : '❌ Failed');
    
    // Test 5: Get approved music again
    console.log('\n🎵 Test 5: Fetching approved music again...');
    const approvedResponse2 = await fetch(`${BASE_URL}/api/music/approved?page=1&limit=50`);
    const approvedData2 = await approvedResponse2.json();
    console.log('Approved music count after approval:', approvedData2.data.length);
    
    if (approvedData2.data.some(m => m._id === musicId)) {
      console.log('✅ Uploaded music is now in approved list');
    } else {
      console.log('⚠️ Uploaded music not found in approved list');
    }
    
    // Test 6: Get music stats
    console.log('\n📊 Test 6: Fetching music stats...');
    const statsResponse = await fetch(`${BASE_URL}/admin/music/stats`, {
      credentials: 'include'
    });
    const statsData = await statsResponse.json();
    console.log('Stats:', statsData.data);
    
    // Cleanup
    fs.unlinkSync(audioPath);
    console.log('\n✅ Test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
};

testMusicUpload();
