const https = require('https');

const API_KEY = 'AIzaSyB3nSUVynxjYlxHHuzlklje2D1zAEQBZEA';
const MODEL = 'gemini-2.5-flash'; // Correct model name

async function testGeminiAPI() {
  console.log('✅ Testing Gemini API with correct model...\n');
  console.log(`API Key: ${API_KEY.substring(0, 10)}...${API_KEY.substring(-5)}`);
  console.log(`Model: ${MODEL}\n`);

  const payload = {
    contents: [
      {
        parts: [
          {
            text: 'Say hello and confirm you are working. Keep response short.'
          }
        ]
      }
    ]
  };

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/${MODEL}:generateContent?key=${API_KEY}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(JSON.stringify(payload))
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);

          if (res.statusCode === 200) {
            console.log('✅ SUCCESS! API Key is VALID and working!\n');
            if (response.candidates && response.candidates[0]) {
              const text = response.candidates[0].content.parts[0].text;
              console.log('Gemini Response:');
              console.log(`"${text}"\n`);
              console.log('📊 Response Details:');
              console.log(`- Status: ${res.statusCode}`);
              console.log(`- Model: ${MODEL}`);
              console.log(`- Finish Reason: ${response.candidates[0].finishReason}`);
            }
          } else {
            console.log('❌ API Error:');
            console.log(`Status Code: ${res.statusCode}`);
            if (response.error) {
              console.log(`Error: ${response.error.message}`);
            }
          }
          resolve(response);
        } catch (e) {
          console.log('Parse Error:', e.message);
          console.log('Raw Response:', data);
          reject(e);
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Request Error:', error.message);
      reject(error);
    });

    req.write(JSON.stringify(payload));
    req.end();
  });
}

testGeminiAPI().catch(err => {
  console.error('Test failed:', err.message);
  process.exit(1);
});
