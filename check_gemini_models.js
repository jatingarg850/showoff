const https = require('https');

const API_KEY = 'AIzaSyB3nSUVynxjYlxHHuzlklje2D1zAEQBZEA';

async function listAvailableModels() {
  console.log('🔍 Fetching available Gemini models...\n');

  const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${API_KEY}`;

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models?key=${API_KEY}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
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
          console.log('Available Models:\n');
          
          if (response.models) {
            response.models.forEach((model, index) => {
              console.log(`${index + 1}. ${model.name}`);
              console.log(`   Display Name: ${model.displayName}`);
              console.log(`   Supported Methods: ${model.supportedGenerationMethods?.join(', ')}`);
              console.log('');
            });
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

    req.end();
  });
}

listAvailableModels().catch(err => {
  console.error('Failed:', err.message);
  process.exit(1);
});
