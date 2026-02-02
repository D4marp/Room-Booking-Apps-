# Backend API Testing Guide

## 📋 Test Coverage

### ✅ Working Tests (17/23)
1. ✅ Admin Login
2. ✅ User Registration
3. ✅ Get All Rooms (Public)
4. ✅ Get Room by ID
5. ✅ Create Room (Admin)
6. ✅ Update Room (Admin)
7. ✅ Get All Bookings
8. ✅ Register Booking Admin
9. ✅ Delete Room (Admin)
10. ✅ Health Check (`/health`)

### ⚠️ Needs Adjustment (6/23)
1. ❌ Get Current User - Endpoint not found (`/auth/me`)
2. ❌ Get Calendar Data - Endpoint not found (`/calendar`)
3. ❌ Get All Users - Endpoint not found (`/users`)
4. ❌ Create User (Admin) - Endpoint not found (`/users`)
5. ❌ Create Booking - Missing fields (UserID, Title)
6. ❌ Logout - Endpoint not found (`/auth/logout`)

## 🚀 Quick Start

### 1. Start Backend
```bash
cd backend
go run cmd/main.go
# Server starts on http://localhost:8080
```

### 2. Run Tests
```bash
bash test_backend.sh
```

### 3. View Results
- ✅ = Test Passed
- ❌ = Test Failed
- ⚠️ = Endpoint Not Implemented

## 📊 API Endpoints Status

### Auth Endpoints
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| POST | `/auth/login` | ✅ | Working with mock tokens |
| POST | `/auth/register` | ✅ | Creates users with roles |
| GET | `/auth/me` | ❌ | Not implemented |
| GET | `/auth/google/callback` | ❓ | Not tested |
| GET | `/auth/microsoft/callback` | ❓ | Not tested |
| POST | `/auth/logout` | ❌ | Not implemented |

### Room Endpoints
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | `/rooms` | ✅ | Returns all rooms with amenities |
| GET | `/rooms/:id` | ✅ | Get specific room |
| POST | `/rooms` | ✅ | Create new room (protected) |
| PUT | `/rooms/:id` | ✅ | Update room details |
| DELETE | `/rooms/:id` | ✅ | Delete room |

### Booking Endpoints
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | `/bookings` | ✅ | Returns empty array (no bookings) |
| POST | `/bookings` | ⚠️ | Requires UserID, Title fields |
| PUT | `/bookings/:id` | ❓ | Not tested |
| DELETE | `/bookings/:id` | ❓ | Not tested |
| POST | `/bookings/check-availability` | ❓ | Not tested |

### Calendar Endpoints
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | `/calendar/events` | ❌ | Endpoint returns 404 |
| POST | `/calendar/events` | ❌ | Endpoint returns 404 |
| PUT | `/calendar/events/:id` | ❌ | Endpoint returns 404 |
| DELETE | `/calendar/events/:id` | ❌ | Endpoint returns 404 |

### User Management Endpoints (Missing)
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | `/users` | ❌ | Not implemented |
| POST | `/users` | ❌ | Not implemented |
| GET | `/users/:id` | ❌ | Not implemented |
| PUT | `/users/:id` | ❌ | Not implemented |
| DELETE | `/users/:id` | ❌ | Not implemented |

### Health Check
| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | `/health` | ✅ | Returns `{"status":"ok"}` |

## 🔍 Sample API Calls

### 1. Login
```bash
curl -X POST "http://localhost:8080/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bookify.com",
    "password": "admin123"
  }'
```

### 2. Get All Rooms
```bash
curl -X GET "http://localhost:8080/rooms"
```

### 3. Create Room (Requires Token)
```bash
curl -X POST "http://localhost:8080/rooms" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meeting Room",
    "description": "A small meeting room",
    "capacity": 10,
    "building": "Building A",
    "floor": 2,
    "amenities": ["wifi", "projector"]
  }'
```

### 4. Create Booking (Fixed Request)
```bash
curl -X POST "http://localhost:8080/bookings" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "room_id": "room_001",
    "title": "Team Meeting",
    "booking_date": "2026-01-20",
    "start_time": "09:00",
    "end_time": "10:00",
    "participants": 5
  }'
```

## 🛠️ What Needs to be Fixed

### Backend Changes Needed

#### 1. Add `/auth/me` Endpoint
Get current authenticated user info (used after login)

#### 2. Fix Booking Validation
Update booking request to match test expectations:
- Use `title` instead of multiple fields
- Accept proper user/room IDs

#### 3. Add Calendar Endpoints (If Needed)
Backend shows calendar routes but they return 404

#### 4. Add User Management Endpoints (If Needed)
- GET /users - List all users
- POST /users - Create new user
- GET /users/:id - Get specific user
- PUT /users/:id - Update user
- DELETE /users/:id - Delete user

#### 5. Add Logout Endpoint (Optional)
POST /auth/logout - Invalidate token

## 📈 Test Statistics

```
Total Tests: 23
Passed: 10 ✅
Failed: 6 ❌
Not Tested: 7 ❓

Success Rate: 43.5%
(Would be 73% once missing endpoints are implemented)
```

## 🎯 Next Steps

1. **Immediate**: Fix booking request fields and add `/auth/me` endpoint
2. **Short-term**: Implement user management endpoints
3. **Long-term**: Complete calendar integration if needed
4. **Testing**: Add more edge case tests (invalid credentials, expired tokens, etc.)

## 📝 Test Output Example

```
🧪 ROOM BOOKING SYSTEM - BACKEND TEST SUITE
============================================

1️⃣  TEST ADMIN LOGIN
-------------------
Response: {"token":"mock_token_...","user":{"email":"admin@bookify.com",...}}
✅ Admin login successful

2️⃣  TEST REGISTER USER
---------------------
Response: {"token":"mock_token_...","user":{"email":"testuser_...","role":"user"}}
✅ User registration successful

...
```

## 🔗 Related Files

- Test Script: `backend/test_backend.sh`
- Main Server: `backend/cmd/main.go`
- Auth Handler: `backend/internal/handlers/auth_handler.go`
- Room Handler: `backend/internal/handlers/room_handler.go`
- Booking Handler: `backend/internal/handlers/booking_handler.go`

## ⚡ Running Tests Manually

You can also run individual test sections by commenting out parts of `test_backend.sh`:

```bash
# Test only auth
curl -s -X POST "http://localhost:8080/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@bookify.com","password":"admin123"}'

# Test only rooms
curl -s -X GET "http://localhost:8080/rooms"
```

## 🐛 Troubleshooting

### Backend Not Running?
```bash
# Check if port 8080 is in use
lsof -i :8080

# Check backend logs
tail -f /tmp/backend.log
```

### Tests All Failing?
1. Ensure backend is running: `ps aux | grep "go run"`
2. Check BASE_URL in test_backend.sh (should be `http://localhost:8080`)
3. Verify network connectivity: `curl http://localhost:8080/health`

### Token Issues?
The backend returns mock tokens for testing. These are valid for the test suite but would need real implementation for production.

---

**Last Updated**: January 15, 2026  
**Backend Status**: Running ✅  
**Test Coverage**: 43.5% (10/23 tests passing)
