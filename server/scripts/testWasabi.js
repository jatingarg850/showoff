require('dotenv').config();
const { S3Client, ListBucketsCommand, PutObjectCommand } = require('@aws-sdk/client-s3');

const wasabiClient = new S3Client({
  endpoint: process.env.WASABI_ENDPOINT,
  region: process.env.WASABI_REGION,
  credentials: {
    accessKeyId: process.env.WASABI_ACCESS_KEY_ID,
    secretAccessKey: process.env.WASABI_SECRET_ACCESS_KEY,
  },
});

async function testWasabiConnection() {
  console.log('Testing Wasabi S3 Connection...\n');
  console.log('Configuration:');
  console.log('- Bucket:', process.env.WASABI_BUCKET_NAME);
  console.log('- Region:', process.env.WASABI_REGION);
  console.log('- Endpoint:', process.env.WASABI_ENDPOINT);
  console.log('- Access Key:', process.env.WASABI_ACCESS_KEY_ID.substring(0, 8) + '...\n');

  try {
    // Test 1: List buckets
    console.log('Test 1: Listing buckets...');
    const listCommand = new ListBucketsCommand({});
    const listResponse = await wasabiClient.send(listCommand);
    console.log('✓ Successfully connected to Wasabi!');
    console.log('Available buckets:', listResponse.Buckets.map(b => b.Name).join(', '));

    // Test 2: Upload a test file
    console.log('\nTest 2: Uploading test file...');
    const testContent = 'This is a test file from ShowOff Life app';
    const uploadCommand = new PutObjectCommand({
      Bucket: process.env.WASABI_BUCKET_NAME,
      Key: 'test/test-file.txt',
      Body: testContent,
      ContentType: 'text/plain',
      ACL: 'public-read',
    });
    
    await wasabiClient.send(uploadCommand);
    console.log('✓ Test file uploaded successfully!');
    
    const fileUrl = `${process.env.WASABI_ENDPOINT}/${process.env.WASABI_BUCKET_NAME}/test/test-file.txt`;
    console.log('File URL:', fileUrl);

    console.log('\n✅ All tests passed! Wasabi S3 is configured correctly.');
    console.log('\nYour uploads will be stored at:');
    console.log(`${process.env.WASABI_ENDPOINT}/${process.env.WASABI_BUCKET_NAME}/`);
    
  } catch (error) {
    console.error('\n❌ Error testing Wasabi connection:');
    console.error('Error code:', error.Code || error.name);
    console.error('Error message:', error.message);
    
    if (error.Code === 'InvalidAccessKeyId') {
      console.error('\n💡 Tip: Check your WASABI_ACCESS_KEY_ID in .env file');
    } else if (error.Code === 'SignatureDoesNotMatch') {
      console.error('\n💡 Tip: Check your WASABI_SECRET_ACCESS_KEY in .env file');
    } else if (error.Code === 'NoSuchBucket') {
      console.error('\n💡 Tip: The bucket "' + process.env.WASABI_BUCKET_NAME + '" does not exist');
      console.error('Create it in your Wasabi dashboard or update WASABI_BUCKET_NAME');
    }
  }
}

testWasabiConnection();
