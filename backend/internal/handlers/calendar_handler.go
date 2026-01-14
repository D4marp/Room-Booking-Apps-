package handlers

import (
	"net/http"

	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
)

type CalendarHandler struct {
	googleCalendarService    *services.GoogleCalendarService
	microsoftCalendarService *services.MicrosoftCalendarService
	firebaseService          *services.FirebaseService
}

type EventRequest struct {
	Title       string `json:"title" binding:"required"`
	Description string `json:"description"`
	StartTime   string `json:"start_time" binding:"required"`
	EndTime     string `json:"end_time" binding:"required"`
	CalendarType string `json:"calendar_type"` // "google" or "microsoft"
}

func NewCalendarHandler(
	gcs *services.GoogleCalendarService,
	mcs *services.MicrosoftCalendarService,
	fs *services.FirebaseService,
) *CalendarHandler {
	return &CalendarHandler{
		googleCalendarService:    gcs,
		microsoftCalendarService: mcs,
		firebaseService:          fs,
	}
}

func (ch *CalendarHandler) GetEvents(c *gin.Context) {
	calendarType := c.Query("type") // "google" or "microsoft"
	
	// TODO: Get user access token from request/session
	// TODO: Implement fetching events based on calendar type
	
	c.JSON(http.StatusOK, gin.H{"message": "Get events endpoint"})
}

func (ch *CalendarHandler) CreateEvent(c *gin.Context) {
	var req EventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Create event based on calendar type
	c.JSON(http.StatusCreated, gin.H{"message": "Event created"})
}

func (ch *CalendarHandler) UpdateEvent(c *gin.Context) {
	eventID := c.Param("id")
	var req EventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Update event based on calendar type
	c.JSON(http.StatusOK, gin.H{"message": "Event updated", "event_id": eventID})
}

func (ch *CalendarHandler) DeleteEvent(c *gin.Context) {
	eventID := c.Param("id")
	
	// TODO: Delete event based on calendar type
	c.JSON(http.StatusOK, gin.H{"message": "Event deleted", "event_id": eventID})
}
