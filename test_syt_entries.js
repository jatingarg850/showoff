const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:5000';

async function testSYTEntries() {
  console.log('🧪 Testing SYT Entries API\n');

  try {
    // Test 1: Get all entries
    console.log('1️⃣ Testing GET /api/syt/entries (all entries)');
    const allResponse = await fetch(`${BASE_URL}/api/syt/entries`);
    const allData = await allResponse.json();
    console.log('Status:', allResponse.status);
    console.log('Response:', JSON.stringify(allData, null, 2));
    console.log('Total entries:', allData.data?.length || 0);
    console.log('');

    // Test 2: Get weekly entries
    console.log('2️⃣ Testing GET /api/syt/entries?filter=weekly');
    const weeklyResponse = await fetch(`${BASE_URL}/api/syt/entries?filter=weekly`);
    const weeklyData = await weeklyResponse.json();
    console.log('Status:', weeklyResponse.status);
    console.log('Response:', JSON.stringify(weeklyData, null, 2));
    console.log('Weekly entries:', weeklyData.data?.length || 0);
    console.log('');

    // Test 3: Get current competition info
    console.log('3️⃣ Testing GET /api/syt/current-competition?type=weekly');
    const compResponse = await fetch(`${BASE_URL}/api/syt/current-competition?type=weekly`);
    const compData = await compResponse.json();
    console.log('Status:', compResponse.status);
    console.log('Response:', JSON.stringify(compData, null, 2));
    console.log('');

    // Test 4: Get leaderboard
    console.log('4️⃣ Testing GET /api/syt/leaderboard?type=weekly');
    const leaderResponse = await fetch(`${BASE_URL}/api/syt/leaderboard?type=weekly`);
    const leaderData = await leaderResponse.json();
    console.log('Status:', leaderResponse.status);
    console.log('Response:', JSON.stringify(leaderData, null, 2));
    console.log('Leaderboard entries:', leaderData.data?.length || 0);
    console.log('');

    // Summary
    console.log('📊 SUMMARY:');
    console.log('- All entries:', allData.data?.length || 0);
    console.log('- Weekly entries:', weeklyData.data?.length || 0);
    console.log('- Has active competition:', compData.data?.hasActiveCompetition || false);
    console.log('- Leaderboard entries:', leaderData.data?.length || 0);

    if (weeklyData.data?.length > 0) {
      console.log('\n✅ SUCCESS: Entries are being returned!');
      console.log('\nSample entry:');
      const sample = weeklyData.data[0];
      console.log('- ID:', sample._id);
      console.log('- Title:', sample.title);
      console.log('- User:', sample.user?.username);
      console.log('- Competition Type:', sample.competitionType);
      console.log('- Competition Period:', sample.competitionPeriod);
      console.log('- Votes:', sample.votesCount);
      console.log('- Likes:', sample.likesCount);
    } else {
      console.log('\n⚠️  WARNING: No entries found!');
      console.log('Possible reasons:');
      console.log('1. No active competition exists');
      console.log('2. Entries exist but with different competitionPeriod');
      console.log('3. Entries are not approved (isApproved: false)');
      console.log('4. Entries are not active (isActive: false)');
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testSYTEntries();
