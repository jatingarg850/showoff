const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test user credentials (you'll need to update these)
const TEST_USER_1 = {
  emailOrPhone: 'test1@example.com',
  password: 'password123'
};

const TEST_USER_2 = {
  emailOrPhone: 'test2@example.com',
  password: 'password123'
};

async function testFollowAPI() {
  try {
    console.log('🧪 Testing Follow API...\n');

    // Step 1: Login as user 1
    console.log('1️⃣ Logging in as User 1...');
    const loginResponse1 = await axios.post(`${BASE_URL}/auth/login`, TEST_USER_1);
    
    if (!loginResponse1.data.success) {
      console.log('❌ User 1 login failed:', loginResponse1.data.message);
      return;
    }
    
    const token1 = loginResponse1.data.data.token;
    const user1Id = loginResponse1.data.data.user._id;
    console.log('✅ User 1 logged in:', user1Id);

    // Step 2: Login as user 2
    console.log('\n2️⃣ Logging in as User 2...');
    const loginResponse2 = await axios.post(`${BASE_URL}/auth/login`, TEST_USER_2);
    
    if (!loginResponse2.data.success) {
      console.log('❌ User 2 login failed:', loginResponse2.data.message);
      return;
    }
    
    const user2Id = loginResponse2.data.data.user._id;
    console.log('✅ User 2 logged in:', user2Id);

    // Step 3: User 1 follows User 2
    console.log('\n3️⃣ User 1 following User 2...');
    try {
      const followResponse = await axios.post(
        `${BASE_URL}/follow/${user2Id}`,
        {},
        {
          headers: {
            'Authorization': `Bearer ${token1}`,
            'Content-Type': 'application/json'
          }
        }
      );
      console.log('✅ Follow successful:', followResponse.data);
    } catch (error) {
      console.log('❌ Follow failed:', error.response?.data || error.message);
    }

    // Step 4: Check if following
    console.log('\n4️⃣ Checking if User 1 is following User 2...');
    try {
      const checkResponse = await axios.get(
        `${BASE_URL}/follow/check/${user2Id}`,
        {
          headers: {
            'Authorization': `Bearer ${token1}`,
            'Content-Type': 'application/json'
          }
        }
      );
      console.log('✅ Check following:', checkResponse.data);
    } catch (error) {
      console.log('❌ Check following failed:', error.response?.data || error.message);
    }

    // Step 5: Get User 2's followers
    console.log('\n5️⃣ Getting User 2 followers...');
    try {
      const followersResponse = await axios.get(
        `${BASE_URL}/follow/followers/${user2Id}`,
        {
          headers: {
            'Authorization': `Bearer ${token1}`,
            'Content-Type': 'application/json'
          }
        }
      );
      console.log('✅ Followers:', followersResponse.data);
    } catch (error) {
      console.log('❌ Get followers failed:', error.response?.data || error.message);
    }

    // Step 6: Unfollow
    console.log('\n6️⃣ User 1 unfollowing User 2...');
    try {
      const unfollowResponse = await axios.delete(
        `${BASE_URL}/follow/${user2Id}`,
        {
          headers: {
            'Authorization': `Bearer ${token1}`,
            'Content-Type': 'application/json'
          }
        }
      );
      console.log('✅ Unfollow successful:', unfollowResponse.data);
    } catch (error) {
      console.log('❌ Unfollow failed:', error.response?.data || error.message);
    }

    console.log('\n✅ Follow API test completed!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

// Run the test
testFollowAPI();
