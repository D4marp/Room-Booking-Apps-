package handlers

import (
	"net/http"
	"time"

	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type RoomHandler struct {
	firebaseService *services.FirebaseService
}

type RoomRequest struct {
	Name        string   `json:"name" binding:"required"`
	Description string   `json:"description"`
	Capacity    int      `json:"capacity" binding:"required"`
	Location    string   `json:"location"`
	Amenities   []string `json:"amenities"`
}

type RoomResponse struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Capacity    int       `json:"capacity"`
	Location    string    `json:"location"`
	Amenities   []string  `json:"amenities"`
	Availability bool     `json:"availability"`
	ImageUrl    string    `json:"imageUrl"`
	CreatedAt   string    `json:"createdAt"`
}

// Mock data for testing
var mockRooms = []RoomResponse{
	{
		ID:          "room_001",
		Name:        "Conference Room A",
		Description: "Large conference room with projector",
		Capacity:    20,
		Location:    "Building A, Floor 2",
		Amenities:   []string{"Projector", "Whiteboard", "Video Conference"},
		Availability: true,
		ImageUrl:    "https://via.placeholder.com/400x300?text=Conference+Room+A",
		CreatedAt:   time.Now().Format(time.RFC3339),
	},
	{
		ID:          "room_002",
		Name:        "Meeting Room B",
		Description: "Small meeting room for 1-on-1s",
		Capacity:    4,
		Location:    "Building A, Floor 1",
		Amenities:   []string{"Whiteboard", "WiFi"},
		Availability: true,
		ImageUrl:    "https://via.placeholder.com/400x300?text=Meeting+Room+B",
		CreatedAt:   time.Now().Format(time.RFC3339),
	},
	{
		ID:          "room_003",
		Name:        "Training Room C",
		Description: "Training facility with desks for 15 participants",
		Capacity:    15,
		Location:    "Building B, Floor 3",
		Amenities:   []string{"Projector", "Computers", "WiFi", "AC"},
		Availability: true,
		ImageUrl:    "https://via.placeholder.com/400x300?text=Training+Room+C",
		CreatedAt:   time.Now().Format(time.RFC3339),
	},
	{
		ID:          "room_004",
		Name:        "Seminar Hall",
		Description: "Large seminar hall for presentations",
		Capacity:    50,
		Location:    "Building B, Floor 2",
		Amenities:   []string{"Projector", "Sound System", "WiFi", "AC"},
		Availability: false,
		ImageUrl:    "https://via.placeholder.com/400x300?text=Seminar+Hall",
		CreatedAt:   time.Now().Format(time.RFC3339),
	},
}

// calculateRoomAvailability calculates if a room is available now and for the next 24 hours
func calculateRoomAvailability(roomID string) bool {
	now := time.Now()
	// Check if room is available in next 24 hours for at least 1 hour slot
	return isRoomAvailable(roomID, now, now.Add(1*time.Hour))
}

func NewRoomHandler(fs *services.FirebaseService) *RoomHandler {
	return &RoomHandler{
		firebaseService: fs,
	}
}

func (rh *RoomHandler) GetRooms(c *gin.Context) {
	// Calculate real availability for each room based on bookings
	roomsWithAvailability := make([]RoomResponse, len(mockRooms))
	copy(roomsWithAvailability, mockRooms)
	
	for i := range roomsWithAvailability {
		roomsWithAvailability[i].Availability = calculateRoomAvailability(roomsWithAvailability[i].ID)
	}
	
	c.JSON(http.StatusOK, gin.H{
		"data":    roomsWithAvailability,
		"total":   len(roomsWithAvailability),
		"message": "Rooms retrieved successfully",
	})
}

func (rh *RoomHandler) GetRoomByID(c *gin.Context) {
	roomID := c.Param("id")
	
	// Find room in mock data
	for _, room := range mockRooms {
		if room.ID == roomID {
			c.JSON(http.StatusOK, gin.H{
				"data":    room,
				"message": "Room retrieved successfully",
			})
			return
		}
	}
	
	c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
}

func (rh *RoomHandler) CreateRoom(c *gin.Context) {
	var req RoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	newRoom := RoomResponse{
		ID:            "room_" + uuid.New().String()[:8],
		Name:          req.Name,
		Description:   req.Description,
		Capacity:      req.Capacity,
		Location:      req.Location,
		Amenities:     req.Amenities,
		Availability:  true,
		ImageUrl:      "https://via.placeholder.com/400x300?text=" + req.Name,
		CreatedAt:     time.Now().Format(time.RFC3339),
	}

	// Add to mock data
	mockRooms = append(mockRooms, newRoom)

	c.JSON(http.StatusCreated, gin.H{
		"data":    newRoom,
		"message": "Room created successfully",
	})
}

func (rh *RoomHandler) UpdateRoom(c *gin.Context) {
	roomID := c.Param("id")
	var req RoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find and update room in mock data
	for i, room := range mockRooms {
		if room.ID == roomID {
			mockRooms[i] = RoomResponse{
				ID:           roomID,
				Name:         req.Name,
				Description:  req.Description,
				Capacity:     req.Capacity,
				Location:     req.Location,
				Amenities:    req.Amenities,
				Availability: room.Availability,
				ImageUrl:     room.ImageUrl,
				CreatedAt:    room.CreatedAt,
			}
			c.JSON(http.StatusOK, gin.H{
				"data":    mockRooms[i],
				"message": "Room updated successfully",
			})
			return
		}
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
}

func (rh *RoomHandler) DeleteRoom(c *gin.Context) {
	roomID := c.Param("id")
	
	// Find and remove room from mock data
	for i, room := range mockRooms {
		if room.ID == roomID {
			mockRooms = append(mockRooms[:i], mockRooms[i+1:]...)
			c.JSON(http.StatusOK, gin.H{
				"message": "Room deleted successfully",
			})
			return
		}
	}
	
	c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
}
