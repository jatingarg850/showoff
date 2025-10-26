require('dotenv').config();
const { S3Client, HeadBucketCommand } = require('@aws-sdk/client-s3');

const regions = [
  'us-east-1',
  'us-east-2', 
  'us-west-1',
  'us-west-2',
  'eu-central-1',
  'eu-west-1',
  'eu-west-2',
  'ap-northeast-1',
  'ap-northeast-2',
  'ap-southeast-1',
  'ap-southeast-2',
];

async function detectBucketRegion() {
  console.log('Detecting bucket region for:', process.env.WASABI_BUCKET_NAME);
  console.log('Testing regions...\n');

  for (const region of regions) {
    try {
      const client = new S3Client({
        endpoint: `https://s3.${region}.wasabisys.com`,
        region: region,
        credentials: {
          accessKeyId: process.env.WASABI_ACCESS_KEY_ID,
          secretAccessKey: process.env.WASABI_SECRET_ACCESS_KEY,
        },
      });

      const command = new HeadBucketCommand({
        Bucket: process.env.WASABI_BUCKET_NAME,
      });

      await client.send(command);
      console.log(`✅ Found! Bucket is in region: ${region}`);
      console.log(`Endpoint: https://s3.${region}.wasabisys.com`);
      return region;
    } catch (error) {
      if (error.name !== 'NotFound') {
        console.log(`❌ ${region}: ${error.message}`);
      }
    }
  }

  console.log('\n❌ Could not detect bucket region');
}

detectBucketRegion();
