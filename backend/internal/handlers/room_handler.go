package handlers

import (
	"net/http"

	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
)

type RoomHandler struct {
	firebaseService *services.FirebaseService
}

type RoomRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Capacity    int    `json:"capacity" binding:"required"`
	Location    string `json:"location"`
	Amenities   []string `json:"amenities"`
}

func NewRoomHandler(fs *services.FirebaseService) *RoomHandler {
	return &RoomHandler{
		firebaseService: fs,
	}
}

func (rh *RoomHandler) GetRooms(c *gin.Context) {
	// TODO: Get rooms from Firestore
	c.JSON(http.StatusOK, gin.H{"message": "Get rooms endpoint"})
}

func (rh *RoomHandler) GetRoomByID(c *gin.Context) {
	roomID := c.Param("id")
	// TODO: Get specific room from Firestore
	c.JSON(http.StatusOK, gin.H{"message": "Get room endpoint", "room_id": roomID})
}

func (rh *RoomHandler) CreateRoom(c *gin.Context) {
	var req RoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Create room in Firestore
	c.JSON(http.StatusCreated, gin.H{"message": "Room created"})
}

func (rh *RoomHandler) UpdateRoom(c *gin.Context) {
	roomID := c.Param("id")
	var req RoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Update room in Firestore
	c.JSON(http.StatusOK, gin.H{"message": "Room updated", "room_id": roomID})
}

func (rh *RoomHandler) DeleteRoom(c *gin.Context) {
	roomID := c.Param("id")
	
	// TODO: Delete room from Firestore
	c.JSON(http.StatusOK, gin.H{"message": "Room deleted", "room_id": roomID})
}
