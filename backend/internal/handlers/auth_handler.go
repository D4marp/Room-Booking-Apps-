package handlers

import (
	"net/http"

	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	firebaseService        *services.FirebaseService
	googleCalendarService  *services.GoogleCalendarService
	microsoftCalendarService *services.MicrosoftCalendarService
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
}

func NewAuthHandler(
	fs *services.FirebaseService,
	gcs *services.GoogleCalendarService,
	mcs *services.MicrosoftCalendarService,
) *AuthHandler {
	return &AuthHandler{
		firebaseService:        fs,
		googleCalendarService:  gcs,
		microsoftCalendarService: mcs,
	}
}

func (ah *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Implement login logic with Firebase
	c.JSON(http.StatusOK, gin.H{"message": "Login endpoint"})
}

func (ah *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Implement registration logic with Firebase
	c.JSON(http.StatusOK, gin.H{"message": "Register endpoint"})
}

func (ah *AuthHandler) GoogleCallback(c *gin.Context) {
	code := c.Query("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no authorization code"})
		return
	}

	// TODO: Exchange code for token and create user
	c.JSON(http.StatusOK, gin.H{"message": "Google callback endpoint"})
}

func (ah *AuthHandler) MicrosoftCallback(c *gin.Context) {
	code := c.Query("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no authorization code"})
		return
	}

	// TODO: Exchange code for token and create user
	c.JSON(http.StatusOK, gin.H{"message": "Microsoft callback endpoint"})
}
