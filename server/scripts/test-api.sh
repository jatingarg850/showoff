#!/bin/bash

# ShowOff.life API Test Script
# This script tests all major API endpoints

BASE_URL="http://localhost:3000/api"
TOKEN=""

echo "================================"
echo "ShowOff.life API Test Script"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "1. Testing Health Check..."
response=$(curl -s http://localhost:3000/health)
if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Register User
echo "2. Testing User Registration..."
response=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "displayName": "Test User",
    "password": "password123"
  }')

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Registration successful${NC}"
    TOKEN=$(echo $response | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "Token: $TOKEN"
else
    echo -e "${RED}✗ Registration failed${NC}"
    echo "Response: $response"
fi
echo ""

# Test 3: Login
echo "3. Testing User Login..."
response=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "test@example.com",
    "password": "password123"
  }')

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Login successful${NC}"
    TOKEN=$(echo $response | grep -o '"token":"[^"]*' | cut -d'"' -f4)
else
    echo -e "${RED}✗ Login failed${NC}"
fi
echo ""

# Test 4: Get User Profile
echo "4. Testing Get Profile..."
response=$(curl -s -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $TOKEN")

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Get profile successful${NC}"
else
    echo -e "${RED}✗ Get profile failed${NC}"
fi
echo ""

# Test 5: Get Coin Balance
echo "5. Testing Get Coin Balance..."
response=$(curl -s -X GET "$BASE_URL/coins/balance" \
  -H "Authorization: Bearer $TOKEN")

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Get coin balance successful${NC}"
    echo "Response: $response"
else
    echo -e "${RED}✗ Get coin balance failed${NC}"
fi
echo ""

# Test 6: Spin Wheel
echo "6. Testing Spin Wheel..."
response=$(curl -s -X POST "$BASE_URL/coins/spin-wheel" \
  -H "Authorization: Bearer $TOKEN")

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Spin wheel successful${NC}"
    echo "Response: $response"
else
    echo "Response: $response"
fi
echo ""

# Test 7: Get Feed
echo "7. Testing Get Feed..."
response=$(curl -s -X GET "$BASE_URL/posts/feed" \
  -H "Authorization: Bearer $TOKEN")

if [[ $response == *"success"* ]]; then
    echo -e "${GREEN}✓ Get feed successful${NC}"
else
    echo -e "${RED}✗ Get feed failed${NC}"
fi
echo ""

echo "================================"
echo "API Tests Complete!"
echo "================================"
