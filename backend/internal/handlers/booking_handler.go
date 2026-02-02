package handlers

import (
	"net/http"
	"time"

	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
)

type BookingHandler struct {
	firebaseService *services.FirebaseService
}

type BookingRequest struct {
	RoomID    string `json:"room_id" binding:"required"`
	UserID    string `json:"user_id" binding:"required"`
	StartTime string `json:"start_time" binding:"required"`
	EndTime   string `json:"end_time" binding:"required"`
	Title     string `json:"title" binding:"required"`
	Notes     string `json:"notes"`
}

type AvailabilityCheckRequest struct {
	RoomID    string `json:"room_id" binding:"required"`
	StartTime string `json:"start_time" binding:"required"`
	EndTime   string `json:"end_time" binding:"required"`
}

// Mock booking data (shared with room handler)
type MockBooking struct {
	ID        string
	RoomID    string
	UserID    string
	StartTime time.Time
	EndTime   time.Time
	Title     string
	Status    string // "pending", "confirmed", "cancelled", "completed"
}

var mockBookings = []MockBooking{
	{
		ID:        "booking_001",
		RoomID:    "room_002",
		UserID:    "user_001",
		StartTime: time.Now().Add(2 * time.Hour),
		EndTime:   time.Now().Add(3 * time.Hour),
		Title:     "Team Meeting",
		Status:    "confirmed",
	},
	{
		ID:        "booking_002",
		RoomID:    "room_004",
		UserID:    "user_002",
		StartTime: time.Now().Add(-1 * time.Hour),
		EndTime:   time.Now().Add(5 * time.Hour),
		Title:     "Seminar Session",
		Status:    "confirmed",
	},
}

// isRoomAvailable checks if a room is available at a given time
func isRoomAvailable(roomID string, startTime, endTime time.Time) bool {
	for _, booking := range mockBookings {
		// Skip cancelled bookings
		if booking.Status == "cancelled" {
			continue
		}
		
		// Skip completed bookings
		if booking.Status == "completed" {
			continue
		}
		
		// Check if room ID matches
		if booking.RoomID != roomID {
			continue
		}
		
		// Check for time overlap
		// Overlap exists if: startTime < booking.EndTime AND endTime > booking.StartTime
		if startTime.Before(booking.EndTime) && endTime.After(booking.StartTime) {
			return false
		}
	}
	return true
}

func NewBookingHandler(fs *services.FirebaseService) *BookingHandler {
	return &BookingHandler{
		firebaseService: fs,
	}
}

func (bh *BookingHandler) GetBookings(c *gin.Context) {
	// TODO: Get bookings from Firestore
	c.JSON(http.StatusOK, gin.H{
		"data":    []interface{}{},
		"message": "Get bookings endpoint",
	})
}

// CheckAvailability checks if a room is available for a given time slot
func (bh *BookingHandler) CheckAvailability(c *gin.Context) {
	var req AvailabilityCheckRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	startTime, err := time.Parse(time.RFC3339, req.StartTime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_time format, use RFC3339"})
		return
	}

	endTime, err := time.Parse(time.RFC3339, req.EndTime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end_time format, use RFC3339"})
		return
	}

	// Check room availability (using same logic as room handler)
	available := isRoomAvailable(req.RoomID, startTime, endTime)

	c.JSON(http.StatusOK, gin.H{
		"room_id":     req.RoomID,
		"start_time":  req.StartTime,
		"end_time":    req.EndTime,
		"available":   available,
		"message":     "Room availability checked",
	})
}

func (bh *BookingHandler) CreateBooking(c *gin.Context) {
	var req BookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Create booking in Firestore and sync with calendar
	c.JSON(http.StatusCreated, gin.H{"message": "Booking created"})
}

func (bh *BookingHandler) UpdateBooking(c *gin.Context) {
	bookingID := c.Param("id")
	var req BookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Update booking and sync with calendar
	c.JSON(http.StatusOK, gin.H{"message": "Booking updated", "booking_id": bookingID})
}

func (bh *BookingHandler) DeleteBooking(c *gin.Context) {
	bookingID := c.Param("id")
	
	// TODO: Delete booking and remove from calendar
	c.JSON(http.StatusOK, gin.H{"message": "Booking deleted", "booking_id": bookingID})
}
