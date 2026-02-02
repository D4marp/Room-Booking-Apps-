#!/bin/bash

# Quick Backend Test - Shows only important results

echo "🧪 Quick Backend Test"
echo "===================="
echo ""

# Health check
echo "1. Health Check:"
curl -s http://localhost:8080/health | jq '.' 2>/dev/null || echo "❌ Backend not running"
echo ""

# Login test
echo "2. Admin Login:"
curl -s -X POST "http://localhost:8080/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@bookify.com","password":"admin123"}' | jq '.token' 2>/dev/null || echo "❌ Login failed"
echo ""

# Get rooms
echo "3. Get Rooms:"
curl -s http://localhost:8080/rooms | jq '.total' 2>/dev/null || echo "❌ Failed"
echo ""

# Register user
echo "4. Register User:"
curl -s -X POST "http://localhost:8080/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test_$(date +%s)@bookify.com\",\"password\":\"test123\",\"name\":\"Test User\",\"role\":\"user\"}" | jq '.user.email' 2>/dev/null || echo "❌ Registration failed"
echo ""

echo "✨ Done! Run 'bash test_backend.sh' for full test suite"
