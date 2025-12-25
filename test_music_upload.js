const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const fetch = require('node-fetch');

async function testMusicUpload() {
  try {
    console.log('🎵 Testing Music Upload Endpoint...\n');

    // Create a dummy audio file for testing
    const dummyAudioPath = path.join(__dirname, 'test-audio.mp3');
    
    // Create a simple MP3 header (minimal valid MP3)
    const mp3Header = Buffer.from([
      0xFF, 0xFB, 0x90, 0x00, // MPEG Layer 3 sync word
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ]);
    
    fs.writeFileSync(dummyAudioPath, mp3Header);
    console.log('✅ Created test audio file');

    // Create form data
    const form = new FormData();
    form.append('audio', fs.createReadStream(dummyAudioPath));
    form.append('title', 'Test Song');
    form.append('artist', 'Test Artist');
    form.append('genre', 'pop');
    form.append('mood', 'happy');
    form.append('duration', '180');

    console.log('📤 Sending upload request to http://localhost:3000/admin/music/upload\n');

    const response = await fetch('http://localhost:3000/admin/music/upload', {
      method: 'POST',
      body: form,
      headers: form.getHeaders(),
      credentials: 'include'
    });

    console.log(`📥 Response Status: ${response.status}`);
    console.log(`📥 Response Headers:`, response.headers.raw());

    const data = await response.json();
    console.log('\n📋 Response Body:');
    console.log(JSON.stringify(data, null, 2));

    if (response.ok) {
      console.log('\n✅ Music upload successful!');
    } else {
      console.log('\n❌ Music upload failed!');
    }

    // Cleanup
    fs.unlinkSync(dummyAudioPath);
    console.log('\n🧹 Cleaned up test files');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error);
  }
}

testMusicUpload();
