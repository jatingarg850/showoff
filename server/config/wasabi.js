const { S3Client } = require('@aws-sdk/client-s3');

// Function to create S3-compatible client (Wasabi, Cloudflare R2, AWS S3, etc.)
function createWasabiClient() {
  const bucketName = process.env.WASABI_BUCKET_NAME;
  const region = process.env.WASABI_REGION || 'auto';
  const endpoint = process.env.WASABI_ENDPOINT;
  
  // Check if credentials are configured (not placeholders)
  const isConfigured = bucketName && 
                       process.env.WASABI_ACCESS_KEY_ID && 
                       endpoint &&
                       !bucketName.includes('your_') &&
                       !process.env.WASABI_ACCESS_KEY_ID.includes('your_');

  if (!isConfigured) {
    console.log('⚠️  S3 Storage not configured - using local storage fallback');
    return null;
  }

  console.log('✅ S3-Compatible Storage Configuration:');
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
    forcePathStyle: true, // Use path-style URLs
  });
}

// Create and export the client
const wasabiClient = createWasabiClient();

module.exports = wasabiClient;
