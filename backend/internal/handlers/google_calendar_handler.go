package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
)

type GoogleCalendarHandler struct {
	googleConfig *oauth2.Config
}

type GoogleAuthResponse struct {
	UserID       string `json:"user_id"`
	Email        string `json:"email"`
	CalendarID   string `json:"calendar_id"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

type BookingEventRequest struct {
	BookingID   string    `json:"booking_id" binding:"required"`
	RoomID      string    `json:"room_id" binding:"required"`
	RoomName    string    `json:"room_name" binding:"required"`
	Title       string    `json:"title" binding:"required"`
	Description string    `json:"description"`
	StartTime   time.Time `json:"start_time" binding:"required"`
	EndTime     time.Time `json:"end_time" binding:"required"`
	Attendees   []string  `json:"attendees"`
}

type CalendarEventResponse struct {
	EventID     string    `json:"event_id"`
	BookingID   string    `json:"booking_id"`
	RoomID      string    `json:"room_id"`
	RoomName    string    `json:"room_name"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	StartTime   time.Time `json:"start_time"`
	EndTime     time.Time `json:"end_time"`
	Attendees   []string  `json:"attendees"`
	CreatedAt   time.Time `json:"created_at"`
}

type NotificationRequest struct {
	UserID    string    `json:"user_id" binding:"required"`
	BookingID string    `json:"booking_id" binding:"required"`
	RoomID    string    `json:"room_id" binding:"required"`
	RoomName  string    `json:"room_name" binding:"required"`
	Title     string    `json:"title" binding:"required"`
	StartTime time.Time `json:"start_time" binding:"required"`
	EndTime   time.Time `json:"end_time" binding:"required"`
	UserEmail string    `json:"user_email" binding:"required"`
}

// NewGoogleCalendarHandler membuat handler baru untuk Google Calendar
func NewGoogleCalendarHandler() *GoogleCalendarHandler {
	config := &oauth2.Config{
		ClientID:     os.Getenv("GOOGLE_CLIENT_ID"),
		ClientSecret: os.Getenv("GOOGLE_CLIENT_SECRET"),
		RedirectURL:  os.Getenv("GOOGLE_CALENDAR_REDIRECT_URL"),
		Scopes: []string{
			"https://www.googleapis.com/auth/calendar",
			"https://www.googleapis.com/auth/calendar.events",
			"https://www.googleapis.com/auth/calendar.readonly",
		},
		Endpoint: google.Endpoint,
	}

	return &GoogleCalendarHandler{
		googleConfig: config,
	}
}

// GoogleLogin - Login dengan Google dan simpan token
// POST /calendar/auth/google
func (h *GoogleCalendarHandler) GoogleLogin(c *gin.Context) {
	var req GoogleAuthRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Verifikasi token dengan Google
	userInfo, err := h.verifyGoogleToken(req.IDToken)
	if err != nil {
		log.Printf("Token verification error: %v", err)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	// TODO: Simpan ke database
	// - UserID: userInfo["sub"]
	// - Email: req.Email
	// - AccessToken: req.AccessToken
	// - RefreshToken (dari OAuth flow)
	// - Token Expiry

	resp := GoogleAuthResponse{
		UserID:      userInfo["sub"].(string),
		Email:       req.Email,
		CalendarID:  "primary",
		AccessToken: req.AccessToken,
		ExpiresIn:   3600,
	}

	c.JSON(http.StatusOK, resp)
}

// SyncBookingToCalendar - Sinkronisasi booking ke Google Calendar
// POST /calendar/sync
func (h *GoogleCalendarHandler) SyncBookingToCalendar(c *gin.Context) {
	var req BookingEventRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Ambil token dari database berdasarkan user ID
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Buat event untuk Google Calendar
	event := &calendar.Event{
		Summary:     req.Title,
		Description: req.Description,
		Start: &calendar.EventDateTime{
			DateTime: req.StartTime.Format(time.RFC3339),
			TimeZone: "Asia/Jakarta",
		},
		End: &calendar.EventDateTime{
			DateTime: req.EndTime.Format(time.RFC3339),
			TimeZone: "Asia/Jakarta",
		},
		Location: req.RoomName,
	}

	// Tambah attendees jika ada
	if len(req.Attendees) > 0 {
		for _, attendee := range req.Attendees {
			event.Attendees = append(event.Attendees, &calendar.EventAttendee{
				Email: attendee,
			})
		}
	}

	// Buat custom property untuk tracking booking
	event.ExtendedProperties = &calendar.EventExtendedProperties{
		Private: map[string]string{
			"booking_id": req.BookingID,
			"room_id":    req.RoomID,
		},
	}

	// TODO: Insert ke Google Calendar dengan access token dari database

	resp := CalendarEventResponse{
		BookingID:   req.BookingID,
		RoomID:      req.RoomID,
		RoomName:    req.RoomName,
		Title:       req.Title,
		Description: req.Description,
		StartTime:   req.StartTime,
		EndTime:     req.EndTime,
		Attendees:   req.Attendees,
		CreatedAt:   time.Now(),
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Booking synced to Google Calendar",
		"data":    resp,
	})
}

// GetCalendarEvents - Ambil events dari Google Calendar untuk bulan tertentu
// GET /calendar/events?month=1&year=2024&room_id=room123
func (h *GoogleCalendarHandler) GetCalendarEvents(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	month := c.Query("month")
	year := c.Query("year")
	roomID := c.Query("room_id")

	// TODO: Query events dari database atau Google Calendar
	// Filter berdasarkan:
	// - Month & Year (jika ada)
	// - Room ID (jika ada)
	// - User ID

	// Contoh response
	events := []CalendarEventResponse{}

	c.JSON(http.StatusOK, gin.H{
		"data":  events,
		"count": len(events),
		"filters": gin.H{
			"month":   month,
			"year":    year,
			"room_id": roomID,
		},
	})
}

// GetCalendarEventsByRoom - Ambil events untuk ruangan tertentu
// GET /calendar/rooms/:room_id/events?start_date=2024-01-01&end_date=2024-01-31
func (h *GoogleCalendarHandler) GetCalendarEventsByRoom(c *gin.Context) {
	roomID := c.Param("room_id")
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if roomID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Room ID required"})
		return
	}

	// TODO: Query events dari database
	// Filter:
	// - room_id = roomID
	// - start_time antara startDate dan endDate
	// - status = confirmed/pending

	events := []CalendarEventResponse{}

	c.JSON(http.StatusOK, gin.H{
		"room_id":    roomID,
		"events":     events,
		"count":      len(events),
		"start_date": startDate,
		"end_date":   endDate,
	})
}

// DeleteCalendarEvent - Hapus event dari Google Calendar
// DELETE /calendar/events/:event_id
func (h *GoogleCalendarHandler) DeleteCalendarEvent(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	eventID := c.Param("event_id")
	if eventID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Event ID required"})
		return
	}

	// TODO: Delete dari Google Calendar dan database

	c.JSON(http.StatusOK, gin.H{
		"message":  "Event deleted successfully",
		"event_id": eventID,
	})
}

// SendBookingNotification - Kirim notifikasi untuk booking baru
// POST /calendar/notifications
func (h *GoogleCalendarHandler) SendBookingNotification(c *gin.Context) {
	var req NotificationRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Buat notifikasi message
	message := map[string]interface{}{
		"title":      "New Booking: " + req.Title,
		"body":       fmt.Sprintf("Room %s booked from %s to %s", req.RoomName, req.StartTime.Format("15:04"), req.EndTime.Format("15:04")),
		"booking_id": req.BookingID,
		"room_id":    req.RoomID,
		"timestamp":  time.Now().Unix(),
	}

	// TODO: Kirim ke:
	// 1. Push Notification (Firebase Cloud Messaging / FCM)
	// 2. Email notification
	// 3. In-app notification
	// 4. SMS alerts (optional)

	c.JSON(http.StatusOK, gin.H{
		"message":      "Notification queued for delivery",
		"notification": message,
		"user_id":      req.UserID,
	})
}

// ScheduleReminder - Schedule reminder sebelum meeting
// POST /calendar/reminders
func (h *GoogleCalendarHandler) ScheduleReminder(c *gin.Context) {
	var req struct {
		BookingID      string    `json:"booking_id" binding:"required"`
		UserID         string    `json:"user_id" binding:"required"`
		RoomName       string    `json:"room_name" binding:"required"`
		StartTime      time.Time `json:"start_time" binding:"required"`
		ReminderMinutes int       `json:"reminder_minutes"` // e.g., 15
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.ReminderMinutes == 0 {
		req.ReminderMinutes = 15 // Default 15 minutes
	}

	// TODO: Schedule reminder notification dengan job scheduler (e.g., go-cron)

	reminderTime := req.StartTime.Add(-time.Duration(req.ReminderMinutes) * time.Minute)

	c.JSON(http.StatusOK, gin.H{
		"message":          "Reminder scheduled",
		"booking_id":       req.BookingID,
		"reminder_time":    reminderTime,
		"reminder_minutes": req.ReminderMinutes,
	})
}

// CheckAvailability - Cek ketersediaan ruangan
// GET /calendar/rooms/:room_id/availability?date=2024-01-15
func (h *GoogleCalendarHandler) CheckAvailability(c *gin.Context) {
	roomID := c.Param("room_id")
	date := c.Query("date")

	if roomID == "" || date == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Room ID and date required"})
		return
	}

	// TODO: Ambil semua bookings untuk room di tanggal tertentu
	// Return available time slots

	availability := gin.H{
		"room_id": roomID,
		"date":    date,
		"slots": []gin.H{
			{
				"start": "08:00",
				"end":   "10:00",
				"available": true,
			},
			{
				"start": "10:00",
				"end":   "12:00",
				"available": false,
			},
			{
				"start": "13:00",
				"end":   "15:00",
				"available": true,
			},
		},
	}

	c.JSON(http.StatusOK, availability)
}

// Helper: Verifikasi Google ID Token
func (h *GoogleCalendarHandler) verifyGoogleToken(idToken string) (map[string]interface{}, error) {
	// Verifikasi dengan Google
	url := "https://www.googleapis.com/oauth2/v1/tokeninfo?id_token=" + idToken
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, err
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("token verification failed: %s", string(body))
	}

	return result, nil
}

// Helper: Buat Google Calendar Service
func (h *GoogleCalendarHandler) createCalendarService(ctx context.Context, accessToken string) (*calendar.Service, error) {
	token := &oauth2.Token{
		AccessToken: accessToken,
		TokenType:   "Bearer",
	}

	client := h.googleConfig.Client(ctx, token)
	return calendar.NewService(ctx, option.WithHTTPClient(client))
}
