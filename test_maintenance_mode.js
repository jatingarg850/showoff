// Test script for maintenance mode
// Usage: node test_maintenance_mode.js

const http = require('http');

const baseUrl = 'http://localhost:5000';

// Test 1: Enable maintenance mode
console.log('🔧 Test 1: Enabling maintenance mode...\n');

const enableOptions = {
  hostname: 'localhost',
  port: 5000,
  path: '/coddyIO',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  }
};

const enableReq = http.request(enableOptions, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Response:', JSON.parse(data));
    console.log('\n---\n');
    
    // Test 2: Check status
    console.log('📊 Test 2: Checking maintenance mode status...\n');
    
    const statusOptions = {
      hostname: 'localhost',
      port: 5000,
      path: '/coddyIO/status',
      method: 'GET'
    };
    
    const statusReq = http.request(statusOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Response:', JSON.parse(data));
        console.log('\n---\n');
        
        // Test 3: Try to access API (should be blocked)
        console.log('🚫 Test 3: Trying to access API (should be blocked)...\n');
        
        const apiOptions = {
          hostname: 'localhost',
          port: 5000,
          path: '/api/auth/me',
          method: 'GET',
          headers: {
            'Authorization': 'Bearer test-token'
          }
        };
        
        const apiReq = http.request(apiOptions, (res) => {
          let data = '';
          res.on('data', (chunk) => {
            data += chunk;
          });
          res.on('end', () => {
            console.log('Status:', res.statusCode);
            console.log('Response:', JSON.parse(data));
            console.log('\n---\n');
            
            // Test 4: Disable maintenance mode
            console.log('✅ Test 4: Disabling maintenance mode...\n');
            
            const disableOptions = {
              hostname: 'localhost',
              port: 5000,
              path: '/coddyIO',
              method: 'POST',
              headers: {
                'Content-Type': 'application/json'
              }
            };
            
            const disableReq = http.request(disableOptions, (res) => {
              let data = '';
              res.on('data', (chunk) => {
                data += chunk;
              });
              res.on('end', () => {
                console.log('Status:', res.statusCode);
                console.log('Response:', JSON.parse(data));
                console.log('\n---\n');
                
                // Test 5: Check status again
                console.log('📊 Test 5: Checking maintenance mode status again...\n');
                
                const finalStatusOptions = {
                  hostname: 'localhost',
                  port: 5000,
                  path: '/coddyIO/status',
                  method: 'GET'
                };
                
                const finalStatusReq = http.request(finalStatusOptions, (res) => {
                  let data = '';
                  res.on('data', (chunk) => {
                    data += chunk;
                  });
                  res.on('end', () => {
                    console.log('Status:', res.statusCode);
                    console.log('Response:', JSON.parse(data));
                    console.log('\n✅ All tests completed!');
                  });
                });
                
                finalStatusReq.on('error', (e) => {
                  console.error('Error:', e);
                });
                
                finalStatusReq.end();
              });
            });
            
            disableReq.on('error', (e) => {
              console.error('Error:', e);
            });
            
            disableReq.write(JSON.stringify({ password: 'paid' }));
            disableReq.end();
          });
        });
        
        apiReq.on('error', (e) => {
          console.error('Error:', e);
        });
        
        apiReq.end();
      });
    });
    
    statusReq.on('error', (e) => {
      console.error('Error:', e);
    });
    
    statusReq.end();
  });
});

enableReq.on('error', (e) => {
  console.error('Error:', e);
});

enableReq.write(JSON.stringify({ password: 'jatingarg' }));
enableReq.end();
