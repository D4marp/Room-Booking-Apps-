# Flutter & Golang Backend Testing Guide

## Prerequisites

- Flutter SDK installed
- Golang 1.21+ installed
- Android Studio / iOS Xcode (untuk Flutter testing)
- Postman atau curl (untuk API testing)

## Backend Setup

### 1. Start Golang Backend

```bash
cd backend

# Install dependencies
go mod download
go mod tidy

# Run in development mode
go run ./cmd/main.go
```

Backend akan start di: `http://localhost:8080`

### 2. Verify Backend is Running

```bash
# Check health endpoint
curl http://localhost:8080/health

# Expected response
{"status":"ok"}
```

## Testing Endpoints

### Auth Endpoints

#### Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "token": "mock_token_...",
  "user": {
    "id": "user_...",
    "email": "user@test.com",
    "name": "user@test.com",
    "role": "user",
    "createdAt": "2024-01-14T10:00:00Z"
  }
}
```

#### Register
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@test.com",
    "password": "password123"
  }'
```

### Room Endpoints

#### Get All Rooms
```bash
curl http://localhost:8080/rooms
```

**Response:**
```json
{
  "data": [
    {
      "id": "room_001",
      "name": "Conference Room A",
      "description": "Large conference room with projector",
      "capacity": 20,
      "location": "Building A, Floor 2",
      "amenities": ["Projector", "Whiteboard", "Video Conference"],
      "availability": true,
      "imageUrl": "https://via.placeholder.com/...",
      "createdAt": "2024-01-14T10:00:00Z"
    },
    ...
  ],
  "total": 4,
  "message": "Rooms retrieved successfully"
}
```

#### Get Room by ID
```bash
curl http://localhost:8080/rooms/room_001
```

#### Create Room (Admin Only)
```bash
curl -X POST http://localhost:8080/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name": "New Meeting Room",
    "description": "A new meeting room",
    "capacity": 10,
    "location": "Building C, Floor 1",
    "amenities": ["WiFi", "Whiteboard"]
  }'
```

#### Update Room
```bash
curl -X PUT http://localhost:8080/rooms/room_001 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name": "Updated Room Name",
    "description": "Updated description",
    "capacity": 25,
    "location": "Building A, Floor 3",
    "amenities": ["Projector", "Whiteboard"]
  }'
```

#### Delete Room
```bash
curl -X DELETE http://localhost:8080/rooms/room_001 \
  -H "Authorization: Bearer <token>"
```

### Booking Endpoints

#### Get All Bookings
```bash
curl http://localhost:8080/bookings
```

#### Create Booking
```bash
curl -X POST http://localhost:8080/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "room_id": "room_001",
    "user_id": "user_123",
    "start_time": "2024-01-14T10:00:00Z",
    "end_time": "2024-01-14T11:00:00Z",
    "title": "Team Meeting"
  }'
```

## Flutter Testing

### 1. Configuration

Update API base URL in `lib/utils/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  // or 'http://<your-machine-ip>:8080' for device testing
}
```

### 2. Test Credentials

**Admin Account:**
- Email: `admin@bookify.com`
- Password: `any_password`
- Role: admin (dapat akses Admin CMS)

**User Account:**
- Email: `user@test.com`
- Password: `any_password`
- Role: user

### 3. Run Flutter App

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with debug output
flutter run -v
```

### 4. Test Scenarios

#### Scenario 1: User Registration & Login
1. Launch app
2. Tap "Sign Up"
3. Enter:
   - Name: "Test User"
   - Email: "testuser@example.com"
   - Password: "password123"
4. Verify login successful → Navigate to Main Screen
5. Check 3 tabs visible: Home, Rooms, Admin (if admin)

#### Scenario 2: View Rooms
1. Login as user
2. Tap "Rooms" tab
3. Verify 4 mock rooms displayed:
   - Conference Room A
   - Meeting Room B
   - Training Room C
   - Seminar Hall
4. Pull to refresh → Should reload rooms from API

#### Scenario 3: Admin Access
1. Login with admin@bookify.com
2. Should see 3 tabs: Home, Rooms, **Admin CMS**
3. Tap Admin CMS tab
4. Verify 3 sub-sections:
   - Rooms Management
   - Bookings Management
   - Users Management

#### Scenario 4: Admin Room Management
1. In Admin CMS → Rooms tab
2. Click "Add Room"
3. Fill form:
   - Name: "New Test Room"
   - Description: "Test room"
   - Capacity: 10
   - Location: "Building D"
   - Amenities: "WiFi, Projector"
4. Verify room added to table
5. Edit room → Update name
6. Delete room → Confirm deletion

## Troubleshooting

### Backend Connection Error

**Error:** "Connection refused" atau "Failed to connect"

**Solution:**
```bash
# Verify backend is running
lsof -i :8080

# Check firewall
sudo iptables -L | grep 8080

# If on device/emulator, use machine IP
ipconfig getifaddr en0  # macOS
ifconfig | grep inet   # Linux
ipconfig              # Windows
```

### CORS Error

**Error:** "CORS policy" blocked the request

**Solution:** Backend CORS middleware sudah ditambahkan di main.go. Jika masih error:
- Check browser console untuk details
- Verify backend CORS headers

### API Returns 401 Unauthorized

**Error:** "Unauthorized - Please login again"

**Solution:**
- Token expired → Login ulang
- Check Authorization header format: `Bearer <token>`

### Rooms Not Loading

**Error:** Empty room list atau error message

**Solution:**
```bash
# Test endpoint directly
curl http://localhost:8080/rooms

# Check backend logs untuk error details
# Restart backend: go run ./cmd/main.go
```

### Flutter Build Error

**Error:** "http" package not found

**Solution:**
```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

## Performance Testing

### Load Test Backend

```bash
# Install Apache Bench
brew install httpd  # macOS
apt-get install apache2-utils  # Linux

# Run 100 requests with 10 concurrent
ab -n 100 -c 10 http://localhost:8080/health

# Test room endpoint
ab -n 100 -c 10 http://localhost:8080/rooms
```

### Monitor Backend

```bash
# Watch requests in real-time
# Terminal 1: Run backend with verbose logging
go run ./cmd/main.go

# Terminal 2: Make requests
curl http://localhost:8080/rooms
```

## CI/CD Testing

### Automated Backend Tests

```bash
cd backend
go test -v ./...
```

### Automated Flutter Tests

```bash
flutter test

# With coverage
flutter test --coverage
```

## Next Steps

1. **Implement Firebase Integration** - Replace mock auth dengan real Firebase
2. **Add Real Calendar Sync** - Implement Google & Microsoft Calendar APIs
3. **Database Persistence** - Move from mock data ke Firestore
4. **WebSocket for Real-time** - Add real-time updates untuk booking
5. **Error Handling** - Comprehensive error handling dan logging
6. **Authentication** - Proper JWT token management dan refresh

