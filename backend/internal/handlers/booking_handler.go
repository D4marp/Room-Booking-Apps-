package handlers

import (
	"net/http"

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

func NewBookingHandler(fs *services.FirebaseService) *BookingHandler {
	return &BookingHandler{
		firebaseService: fs,
	}
}

func (bh *BookingHandler) GetBookings(c *gin.Context) {
	// TODO: Get bookings from Firestore
	c.JSON(http.StatusOK, gin.H{"message": "Get bookings endpoint"})
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
