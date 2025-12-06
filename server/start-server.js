#!/usr/bin/env node

/**
 * Simple Server Starter
 * Runs the server without PM2
 */

const spawn = require('child_process').spawn;
const path = require('path');

console.log('🚀 Starting ShowOff.life Server...');
console.log('📍 Server will run on port 3000');
console.log('');

// Start the server
const server = spawn('node', ['server.js'], {
  cwd: __dirname,
  stdio: 'inherit',
  shell: true
});

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n\n⛔ Shutting down server...');
  server.kill();
  process.exit(0);
});

server.on('error', (err) => {
  console.error('❌ Error starting server:', err);
  process.exit(1);
});

server.on('exit', (code) => {
  console.log(`\n⛔ Server exited with code ${code}`);
  process.exit(code);
});
