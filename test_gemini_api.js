const https = require('https');

const API_KEY = 'AIzaSyB3nSUVynxjYlxHHuzlklje2D1zAEQBZEA';
const MODEL = 'gemini-1.5-flash';

async function testGeminiAPI() {
  console.log('🔍 Testing Gemini API Key...\n');
  console.log(`API Key: ${API_KEY.substring(0, 10)}...${API_KEY.substring(-5)}`);
  console.log(`Model: ${MODEL}\n`);

  const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}`;

  const payload = {
    contents: [
      {
        parts: [
          {
            text: 'Say hello and confirm you are working'
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
        console.log(`Status Code: ${res.statusCode}`);
        console.log(`Headers: ${JSON.stringify(res.headers, null, 2)}\n`);

        try {
          const response = JSON.parse(data);
          console.log('Response:', JSON.stringify(response, null, 2));

          if (res.statusCode === 200) {
            console.log('\n✅ API Key is VALID and working!');
            if (response.candidates && response.candidates[0]) {
              console.log(`Response: ${response.candidates[0].content.parts[0].text}`);
            }
          } else {
            console.log('\n❌ API Error:');
            if (response.error) {
              console.log(`Error Code: ${response.error.code}`);
              console.log(`Error Message: ${response.error.message}`);
              console.log(`Error Details: ${JSON.stringify(response.error.details, null, 2)}`);
            }
          }
          resolve(response);
        } catch (e) {
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
