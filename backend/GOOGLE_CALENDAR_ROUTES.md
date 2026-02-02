# Google Calendar Routes Configuration

## Endpoints Overview

### Authentication & Setup
```
POST   /calendar/auth/google              - Login with Google
GET    /calendar/auth/callback            - OAuth callback
POST   /calendar/disconnect               - Disconnect Google account
```

### Calendar Operations
```
GET    /calendar/events                   - Get all events
GET    /calendar/rooms/:roomId/events     - Get events for specific room
POST   /calendar/sync                     - Sync booking to Google Calendar
DELETE /calendar/events/:eventId          - Delete event
PATCH  /calendar/events/:eventId          - Update event
```

### Availability & Scheduling
```
GET    /calendar/rooms/:roomId/availability - Check room availability
POST   /calendar/reminders                - Schedule reminder
GET    /calendar/reminders/:bookingId     - Get reminder status
```

### Notifications
```
POST   /calendar/notifications            - Send notification
GET    /calendar/notifications/history    - Get notification history
```

---

## Go Router Implementation

```go
// backend/internal/routes/calendar_routes.go

package routes

import (
    "github.com/gin-gonic/gin"
    "bookify-backend/internal/handlers"
    "bookify-backend/internal/middleware"
)

func SetupCalendarRoutes(router *gin.Engine) {
    calendarHandler := handlers.NewGoogleCalendarHandler()
    
    // Public routes
    public := router.Group("/calendar")
    {
        public.POST("/auth/google", calendarHandler.GoogleLogin)
        public.GET("/auth/callback", calendarHandler.HandleOAuthCallback) // TODO
    }
    
    // Protected routes (require authentication)
    protected := router.Group("/calendar")
    protected.Use(middleware.AuthMiddleware())
    {
        // Calendar events
        protected.GET("/events", calendarHandler.GetCalendarEvents)
        protected.GET("/rooms/:room_id/events", calendarHandler.GetCalendarEventsByRoom)
        protected.POST("/sync", calendarHandler.SyncBookingToCalendar)
        protected.DELETE("/events/:event_id", calendarHandler.DeleteCalendarEvent)
        protected.PATCH("/events/:event_id", calendarHandler.UpdateCalendarEvent) // TODO
        
        // Availability
        protected.GET("/rooms/:room_id/availability", calendarHandler.CheckAvailability)
        
        // Reminders
        protected.POST("/reminders", calendarHandler.ScheduleReminder)
        protected.GET("/reminders/:booking_id", calendarHandler.GetReminder) // TODO
        
        // Notifications
        protected.POST("/notifications", calendarHandler.SendBookingNotification)
        protected.GET("/notifications/history", calendarHandler.GetNotificationHistory) // TODO
        
        // Account
        protected.POST("/disconnect", calendarHandler.DisconnectGoogle) // TODO
    }
}
```

---

## Register Routes di Main

```go
// backend/cmd/main.go

package main

import (
    "github.com/gin-gonic/gin"
    "bookify-backend/internal/routes"
)

func main() {
    router := gin.Default()
    
    // Setup all routes
    routes.SetupBookingRoutes(router)
    routes.SetupRoomRoutes(router)
    routes.SetupAuthRoutes(router)
    routes.SetupCalendarRoutes(router)     // ← Add this
    
    router.Run(":8080")
}
```

---

## Testing Calendar Endpoints

### 1. Google Login
```bash
curl -X POST http://localhost:8080/calendar/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "access_token": "ya29.xxxxx",
    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImtleTEifQ.xxx",
    "email": "user@example.com"
  }'
```

### 2. Sync Booking to Google Calendar
```bash
curl -X POST http://localhost:8080/calendar/sync \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "booking_id": "booking123",
    "room_id": "room001",
    "room_name": "Meeting Room A",
    "title": "Team Meeting",
    "description": "Weekly sync",
    "start_time": "2024-01-15T10:00:00Z",
    "end_time": "2024-01-15T11:00:00Z",
    "attendees": ["user1@example.com", "user2@example.com"]
  }'
```

### 3. Get Calendar Events
```bash
curl -X GET "http://localhost:8080/calendar/events?month=1&year=2024" \
  -H "Authorization: Bearer TOKEN"
```

### 4. Get Room Availability
```bash
curl -X GET "http://localhost:8080/calendar/rooms/room001/availability?date=2024-01-15" \
  -H "Authorization: Bearer TOKEN"
```

### 5. Send Notification
```bash
curl -X POST http://localhost:8080/calendar/notifications \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "booking_id": "booking456",
    "room_name": "Meeting Room A",
    "title": "New Booking Confirmation",
    "start_time": "2024-01-15T10:00:00Z",
    "end_time": "2024-01-15T11:00:00Z",
    "user_email": "user@example.com"
  }'
```

### 6. Schedule Reminder
```bash
curl -X POST http://localhost:8080/calendar/reminders \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "booking_id": "booking789",
    "user_id": "user123",
    "room_name": "Meeting Room A",
    "start_time": "2024-01-15T10:00:00Z",
    "reminder_minutes": 15
  }'
```

---

## Database Schema (Recommended)

### calendar_syncs table
```sql
CREATE TABLE calendar_syncs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_expiry TIMESTAMP,
    calendar_id VARCHAR(255) DEFAULT 'primary',
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    disconnected_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### calendar_events table
```sql
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    google_event_id VARCHAR(255) UNIQUE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id),
    google_calendar_id VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    attendees TEXT[], -- JSON array of emails
    location VARCHAR(255),
    status VARCHAR(50), -- 'confirmed', 'tentative', 'cancelled'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP,
    deleted_at TIMESTAMP
);
```

### notifications table
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id),
    type VARCHAR(50), -- 'booking_confirmation', 'reminder', 'cancellation'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_status VARCHAR(50), -- 'pending', 'sent', 'failed'
    channel VARCHAR(50), -- 'push', 'email', 'in_app', 'sms'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### reminders table
```sql
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    reminder_time TIMESTAMP NOT NULL,
    reminder_type VARCHAR(50), -- 'before_meeting', 'after_meeting'
    minutes_before INT DEFAULT 15,
    status VARCHAR(50), -- 'scheduled', 'sent', 'dismissed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP,
    dismissed_at TIMESTAMP
);
```

---

## Environment Variables (.env)

```env
# Google OAuth
GOOGLE_CLIENT_ID=892585576250-omoh7c39qu33mmo0o6jtat7i33h3a9re.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_client_secret_here
GOOGLE_REDIRECT_URI=http://localhost:8080/calendar/auth/callback

# Firebase Cloud Messaging (untuk push notifications)
FCM_PROJECT_ID=fiyansa-mulya
FCM_PRIVATE_KEY=your_firebase_private_key

# Email Configuration (untuk email notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Timezone
DEFAULT_TIMEZONE=Asia/Jakarta
```

---

## Status: Ready for Development ✅

**Next Steps:**
1. ✅ Create Google Calendar handler
2. ✅ Setup routes
3. ⏳ Implement OAuth callback handler
4. ⏳ Implement database operations
5. ⏳ Setup Firebase Cloud Messaging
6. ⏳ Test all endpoints
