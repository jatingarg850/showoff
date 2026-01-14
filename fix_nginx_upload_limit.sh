#!/bin/bash

# Fix nginx upload limit for large video uploads
# Run this script on your AWS server as root or with sudo

echo "🔧 Fixing nginx upload limit..."

# Backup current config
sudo cp /etc/nginx/sites-available/showoff /etc/nginx/sites-available/showoff.backup

# Create new nginx config with proper limits
sudo tee /etc/nginx/sites-available/showoff > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    # CRITICAL: Increase max body size for large video uploads (500MB)
    client_max_body_size 500M;
    
    # Increase timeouts for large uploads (10 minutes = 600 seconds)
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;
    
    # Increase buffer sizes
    client_body_buffer_size 128k;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable buffering for large uploads
        proxy_request_buffering off;
        proxy_buffering off;
    }

    location /socket.io {
        proxy_pass http://localhost:3000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
EOF

# If you have SSL configured, also update the HTTPS server block
# Check if SSL config exists
if grep -q "listen 443" /etc/nginx/sites-available/showoff.backup 2>/dev/null; then
    echo "⚠️  SSL config detected - you may need to manually add these settings to your HTTPS server block"
fi

# Test nginx config
echo "🧪 Testing nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx config is valid"
    
    # Restart nginx
    echo "🔄 Restarting nginx..."
    sudo systemctl restart nginx
    
    echo "✅ Nginx restarted successfully!"
    echo ""
    echo "📋 Changes made:"
    echo "   - client_max_body_size: 500M (was 1M default)"
    echo "   - proxy timeouts: 600 seconds (10 minutes)"
    echo "   - proxy buffering: disabled for uploads"
    echo ""
    echo "🎬 You should now be able to upload videos up to 500MB!"
else
    echo "❌ Nginx config test failed!"
    echo "🔄 Restoring backup..."
    sudo cp /etc/nginx/sites-available/showoff.backup /etc/nginx/sites-available/showoff
    echo "⚠️  Please check the config manually"
fi
