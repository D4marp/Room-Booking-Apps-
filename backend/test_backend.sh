#!/bin/bash

BASE_URL="http://localhost:8080"
ADMIN_TOKEN=""
USER_TOKEN=""
BOOKING_ADMIN_TOKEN=""

echo "🧪 ROOM BOOKING SYSTEM - BACKEND TEST SUITE"
echo "============================================"
echo ""

# Helper function for colored output
success() {
    echo "✅ $1"
}

error() {
    echo "❌ $1"
}

info() {
    echo "ℹ️  $1"
}

warning() {
    echo "⚠️  $1"
}

# Test 1: Admin Login
echo "1️⃣  TEST ADMIN LOGIN"
echo "-------------------"
ADMIN_LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bookify.com",
    "password": "admin123"
  }')

echo "Response: $ADMIN_LOGIN"
ADMIN_TOKEN=$(echo "$ADMIN_LOGIN" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
ADMIN_ID=$(echo "$ADMIN_LOGIN" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$ADMIN_TOKEN" ]; then
  success "Admin login successful, Token: ${ADMIN_TOKEN:0:20}..."
  info "Admin ID: $ADMIN_ID"
else
  error "Admin login failed"
  echo "Full response: $ADMIN_LOGIN"
fi
echo ""

# Test 2: Register Regular User
echo "2️⃣  TEST REGISTER USER"
echo "---------------------"
USER_EMAIL="testuser_$(date +%s)@bookify.com"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$USER_EMAIL\",
    \"password\": \"user123\",
    \"name\": \"Test User\",
    \"role\": \"user\"
  }")

echo "Response: $REGISTER_RESPONSE"
USER_TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$USER_TOKEN" ]; then
  success "User registration successful, Token: ${USER_TOKEN:0:20}..."
  info "User ID: $USER_ID, Email: $USER_EMAIL"
else
  error "User registration failed"
  echo "Full response: $REGISTER_RESPONSE"
fi
echo ""

# Test 3: Get Current User (Admin)
echo "3️⃣  TEST GET CURRENT USER (ADMIN)"
echo "--------------------------------"
CURRENT_USER=$(curl -s -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $CURRENT_USER"
if echo "$CURRENT_USER" | grep -q '"id"'; then
  success "Get current user successful"
else
  error "Get current user failed"
fi
echo ""

# Test 4: Get All Rooms (Public)
echo "4️⃣  TEST GET ALL ROOMS (PUBLIC)"
echo "-------------------------------"
ROOMS_RESPONSE=$(curl -s -X GET "$BASE_URL/rooms")

echo "Response: $ROOMS_RESPONSE"
ROOM_ID=$(echo "$ROOMS_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if echo "$ROOMS_RESPONSE" | grep -q '\[' || [ ! -z "$ROOM_ID" ]; then
  success "Get rooms successful"
  if [ ! -z "$ROOM_ID" ]; then
    info "Found room ID: $ROOM_ID"
  fi
else
  error "Get rooms failed"
fi
echo ""

# Test 5: Get Room by ID
if [ ! -z "$ROOM_ID" ]; then
echo "5️⃣  TEST GET ROOM BY ID"
echo "-----------------------"
GET_ROOM=$(curl -s -X GET "$BASE_URL/rooms/$ROOM_ID")

echo "Response: $GET_ROOM"
if echo "$GET_ROOM" | grep -q '"name"'; then
  success "Get room by ID successful"
else
  error "Get room by ID failed"
fi
echo ""
fi

# Test 6: Create Room (Admin Only)
echo "6️⃣  TEST CREATE ROOM (ADMIN)"
echo "----------------------------"
ROOM_NAME="Test Room - $(date +%s)"
CREATE_ROOM=$(curl -s -X POST "$BASE_URL/rooms" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$ROOM_NAME\",
    \"description\": \"Test room for API testing\",
    \"capacity\": 20,
    \"building\": \"Building A\",
    \"floor\": 2,
    \"amenities\": [\"wifi\", \"projector\", \"air_conditioning\"]
  }")

echo "Response: $CREATE_ROOM"
NEW_ROOM_ID=$(echo "$CREATE_ROOM" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$NEW_ROOM_ID" ]; then
  success "Create room successful, Room ID: $NEW_ROOM_ID"
  ROOM_ID=$NEW_ROOM_ID
else
  error "Create room failed"
  echo "Full response: $CREATE_ROOM"
fi
echo ""

# Test 7: Update Room (Admin Only)
if [ ! -z "$ROOM_ID" ]; then
echo "7️⃣  TEST UPDATE ROOM (ADMIN)"
echo "----------------------------"
UPDATE_ROOM=$(curl -s -X PUT "$BASE_URL/rooms/$ROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test Room",
    "description": "Updated room description",
    "capacity": 25,
    "amenities": ["wifi", "projector", "air_conditioning", "whiteboard"]
  }')

echo "Response: $UPDATE_ROOM"
if echo "$UPDATE_ROOM" | grep -q '"name"'; then
  success "Update room successful"
else
  error "Update room failed"
fi
echo ""
fi

# Test 8: Create Booking (User)
echo "8️⃣  TEST CREATE BOOKING (USER)"
echo "------------------------------"
BOOKING_DATE=$(date -v+1d +%Y-%m-%d)
CREATE_BOOKING=$(curl -s -X POST "$BASE_URL/bookings" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"room_id\": \"$ROOM_ID\",
    \"booking_date\": \"$BOOKING_DATE\",
    \"start_time\": \"09:00\",
    \"end_time\": \"10:00\",
    \"purpose\": \"Team Meeting\",
    \"participants\": 5
  }")

echo "Response: $CREATE_BOOKING"
BOOKING_ID=$(echo "$CREATE_BOOKING" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$BOOKING_ID" ]; then
  success "Create booking successful, Booking ID: $BOOKING_ID"
else
  error "Create booking failed"
  echo "Full response: $CREATE_BOOKING"
fi
echo ""

# Test 9: Get All Bookings (User)
echo "9️⃣  TEST GET ALL BOOKINGS (USER)"
echo "--------------------------------"
GET_BOOKINGS=$(curl -s -X GET "$BASE_URL/bookings" \
  -H "Authorization: Bearer $USER_TOKEN")

echo "Response: $GET_BOOKINGS"
if echo "$GET_BOOKINGS" | grep -q '\['; then
  success "Get bookings successful"
else
  error "Get bookings failed"
fi
echo ""

# Test 10: Get Booking by ID
if [ ! -z "$BOOKING_ID" ]; then
echo "🔟 TEST GET BOOKING BY ID"
echo "------------------------"
GET_BOOKING=$(curl -s -X GET "$BASE_URL/bookings/$BOOKING_ID" \
  -H "Authorization: Bearer $USER_TOKEN")

echo "Response: $GET_BOOKING"
if echo "$GET_BOOKING" | grep -q '"id"'; then
  success "Get booking by ID successful"
else
  error "Get booking by ID failed"
fi
echo ""
fi

# Test 11: Approve Booking (Admin)
if [ ! -z "$BOOKING_ID" ]; then
echo "1️⃣1️⃣  TEST APPROVE BOOKING (ADMIN)"
echo "-------------------------------"
APPROVE_BOOKING=$(curl -s -X PUT "$BASE_URL/bookings/$BOOKING_ID/approve" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "approved",
    "notes": "Booking approved"
  }')

echo "Response: $APPROVE_BOOKING"
if echo "$APPROVE_BOOKING" | grep -q '"status"'; then
  success "Approve booking successful"
else
  error "Approve booking failed"
fi
echo ""
fi

# Test 12: Get Calendar Data (Public)
echo "1️⃣2️⃣  TEST GET CALENDAR DATA (PUBLIC)"
echo "-----------------------------------"
CALENDAR_DATE=$(date +%Y-%m-%d)
CALENDAR=$(curl -s -X GET "$BASE_URL/calendar?date=$CALENDAR_DATE&room_id=$ROOM_ID")

echo "Response: $CALENDAR"
if echo "$CALENDAR" | grep -q '\['; then
  success "Get calendar data successful"
else
  error "Get calendar data failed"
fi
echo ""

# Test 13: Get All Users (Admin Only)
echo "1️⃣3️⃣  TEST GET ALL USERS (ADMIN)"
echo "------------------------------"
GET_USERS=$(curl -s -X GET "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $GET_USERS"
if echo "$GET_USERS" | grep -q '\['; then
  success "Get all users successful"
else
  error "Get all users failed"
fi
echo ""

# Test 14: Create User (Admin Only)
echo "1️⃣4️⃣  TEST CREATE USER (ADMIN)"
echo "-----------------------------"
NEW_USER_EMAIL="newuser_$(date +%s)@bookify.com"
CREATE_USER=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$NEW_USER_EMAIL\",
    \"name\": \"New Test User\",
    \"password\": \"Pass@123\",
    \"role\": \"user\"
  }")

echo "Response: $CREATE_USER"
NEW_USER_ID=$(echo "$CREATE_USER" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$NEW_USER_ID" ]; then
  success "Create user successful, User ID: $NEW_USER_ID"
else
  error "Create user failed"
  echo "Full response: $CREATE_USER"
fi
echo ""

# Test 15: Update User (Admin Only)
if [ ! -z "$NEW_USER_ID" ]; then
echo "1️⃣5️⃣  TEST UPDATE USER (ADMIN)"
echo "-----------------------------"
UPDATE_USER=$(curl -s -X PUT "$BASE_URL/users/$NEW_USER_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated User Name",
    "role": "booking_admin"
  }')

echo "Response: $UPDATE_USER"
if echo "$UPDATE_USER" | grep -q '"name"'; then
  success "Update user successful"
else
  error "Update user failed"
fi
echo ""
fi

# Test 16: Get User by ID (Admin Only)
if [ ! -z "$NEW_USER_ID" ]; then
echo "1️⃣6️⃣  TEST GET USER BY ID (ADMIN)"
echo "--------------------------------"
GET_USER=$(curl -s -X GET "$BASE_URL/users/$NEW_USER_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $GET_USER"
if echo "$GET_USER" | grep -q '"id"'; then
  success "Get user by ID successful"
else
  error "Get user by ID failed"
fi
echo ""
fi

# Test 17: Register Booking Admin
echo "1️⃣7️⃣  TEST REGISTER BOOKING ADMIN"
echo "--------------------------------"
BOOKING_ADMIN_EMAIL="bookingadmin_$(date +%s)@bookify.com"
REGISTER_BOOKING_ADMIN=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$BOOKING_ADMIN_EMAIL\",
    \"password\": \"admin123\",
    \"name\": \"Booking Admin\",
    \"role\": \"booking_admin\"
  }")

echo "Response: $REGISTER_BOOKING_ADMIN"
BOOKING_ADMIN_TOKEN=$(echo "$REGISTER_BOOKING_ADMIN" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$BOOKING_ADMIN_TOKEN" ]; then
  success "Booking admin registration successful"
else
  error "Booking admin registration failed"
  echo "Full response: $REGISTER_BOOKING_ADMIN"
fi
echo ""

# Test 18: Booking Admin Approve Booking
if [ ! -z "$BOOKING_ID" ] && [ ! -z "$BOOKING_ADMIN_TOKEN" ]; then
echo "1️⃣8️⃣  TEST BOOKING ADMIN APPROVE BOOKING"
echo "--------------------------------------"
BOOKING_ADMIN_APPROVE=$(curl -s -X PUT "$BASE_URL/bookings/$BOOKING_ID/approve" \
  -H "Authorization: Bearer $BOOKING_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "approved",
    "notes": "Approved by booking admin"
  }')

echo "Response: $BOOKING_ADMIN_APPROVE"
if echo "$BOOKING_ADMIN_APPROVE" | grep -q '"status"'; then
  success "Booking admin approve booking successful"
else
  error "Booking admin approve booking failed"
fi
echo ""
fi

# Test 19: Reject Booking (Admin)
if [ ! -z "$BOOKING_ID" ]; then
echo "1️⃣9️⃣  TEST REJECT BOOKING (ADMIN)"
echo "------------------------------"
REJECT_BOOKING=$(curl -s -X PUT "$BASE_URL/bookings/$BOOKING_ID/reject" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "rejected",
    "notes": "Rejected by admin"
  }')

echo "Response: $REJECT_BOOKING"
if echo "$REJECT_BOOKING" | grep -q '"status"'; then
  success "Reject booking successful"
else
  error "Reject booking failed"
fi
echo ""
fi

# Test 20: Delete Booking (User)
if [ ! -z "$BOOKING_ID" ]; then
echo "2️⃣0️⃣  TEST DELETE BOOKING (USER)"
echo "-----------------------------"
DELETE_BOOKING=$(curl -s -X DELETE "$BASE_URL/bookings/$BOOKING_ID" \
  -H "Authorization: Bearer $USER_TOKEN")

echo "Response: $DELETE_BOOKING"
if echo "$DELETE_BOOKING" | grep -q '"message"' || echo "$DELETE_BOOKING" | grep -q '"success"' || [ -z "$DELETE_BOOKING" ]; then
  success "Delete booking successful"
else
  error "Delete booking failed"
fi
echo ""
fi

# Test 21: Delete User (Admin)
if [ ! -z "$NEW_USER_ID" ]; then
echo "2️⃣1️⃣  TEST DELETE USER (ADMIN)"
echo "----------------------------"
DELETE_USER=$(curl -s -X DELETE "$BASE_URL/users/$NEW_USER_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $DELETE_USER"
if echo "$DELETE_USER" | grep -q '"message"' || echo "$DELETE_USER" | grep -q '"success"' || [ -z "$DELETE_USER" ]; then
  success "Delete user successful"
else
  error "Delete user failed"
fi
echo ""
fi

# Test 22: Delete Room (Admin)
if [ ! -z "$ROOM_ID" ]; then
echo "2️⃣2️⃣  TEST DELETE ROOM (ADMIN)"
echo "----------------------------"
DELETE_ROOM=$(curl -s -X DELETE "$BASE_URL/rooms/$ROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $DELETE_ROOM"
if echo "$DELETE_ROOM" | grep -q '"message"' || echo "$DELETE_ROOM" | grep -q '"success"' || [ -z "$DELETE_ROOM" ]; then
  success "Delete room successful"
else
  error "Delete room failed"
fi
echo ""
fi

# Test 23: Logout (Optional - not all backends implement this)
echo "2️⃣3️⃣  TEST LOGOUT"
echo "----------------"
LOGOUT=$(curl -s -X POST "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $LOGOUT"
if echo "$LOGOUT" | grep -q '"success"' || [ -z "$LOGOUT" ]; then
  success "Logout successful"
else
  warning "Logout endpoint may not be implemented"
fi
echo ""

echo "============================================"
echo "✨ TEST SUITE COMPLETE"
echo ""
echo "📊 Summary:"
echo "  - Admin Token: ${ADMIN_TOKEN:0:20}..."
echo "  - User Token: ${USER_TOKEN:0:20}..."
echo "  - Booking Admin Token: ${BOOKING_ADMIN_TOKEN:0:20}..."
echo ""
echo "💡 Tip: Save tokens for manual testing with Postman or other clients"
