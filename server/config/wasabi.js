const { S3Client } = require('@aws-sdk/client-s3');

// Function to create Wasabi client with bucket-specific endpoint
function createWasabiClient() {
  const bucketName = process.env.WASABI_BUCKET_NAME;
  const region = process.env.WASABI_REGION || 'ap-southeast-1';
  
  // Check if credentials are configured (not placeholders)
  const isConfigured = bucketName && 
                       process.env.WASABI_ACCESS_KEY_ID && 
                       !bucketName.includes('your_') &&
                       !process.env.WASABI_ACCESS_KEY_ID.includes('your_');

  if (!isConfigured) {
    console.log('⚠️  Wasabi S3 not configured - using local storage fallback');
    return null;
  }
  
  // Use standard S3 endpoint (not bucket-specific to avoid SSL cert issues)
  // Format: https://s3.region.wasabisys.com
  const endpoint = `https://s3.${region}.wasabisys.com`;

  console.log('✅ Wasabi S3 Configuration:');
  console.log('   - Bucket:', bucketName);
  console.log('   - Region:', region);
  console.log('   - Endpoint:', endpoint);

  return new S3Client({
    endpoint: endpoint,
    region: region,
    credentials: {
      accessKeyId: process.env.WASABI_ACCESS_KEY_ID,
      secretAccessKey: process.env.WASABI_SECRET_ACCESS_KEY,
    },
    forcePathStyle: true, // Use path-style URLs to avoid SSL cert issues
  });
}

// Create and export the client
const wasabiClient = createWasabiClient();

module.exports = wasabiClient;
