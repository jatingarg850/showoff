const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

async function testWithdrawal() {
  try {
    // First login to get token
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      emailOrPhone: 'test@example.com', // Replace with actual test user
      password: 'password123'
    });

    const token = loginResponse.data.data.token;
    console.log('✅ Logged in successfully');

    // Create a test image file (you can use any image)
    const form = new FormData();
    form.append('coinAmount', '100');
    form.append('method', 'upi');
    form.append('upiId', 'test@upi');
    
    // Create a dummy image file for testing
    const testImagePath = path.join(__dirname, 'test_image.jpg');
    if (fs.existsSync(testImagePath)) {
      form.append('idDocuments', fs.createReadStream(testImagePath));
    } else {
      console.log('⚠️  No test image found, sending without documents');
    }

    const response = await axios.post(
      'http://localhost:3000/api/withdrawal/request',
      form,
      {
        headers: {
          ...form.getHeaders(),
          'Authorization': `Bearer ${token}`
        }
      }
    );

    console.log('✅ Withdrawal request successful:');
    console.log(JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    if (error.response?.data) {
      console.error('Full error:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

testWithdrawal();
