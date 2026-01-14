package handlers

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/http"
	"time"

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

type AuthResponse struct {
	Token string                 `json:"token"`
	User  map[string]interface{} `json:"user"`
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

// Generate mock JWT token for testing
func generateMockToken(email string) string {
	hash := sha256.Sum256([]byte(email + time.Now().String()))
	return "mock_token_" + hex.EncodeToString(hash[:])
}

func (ah *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Mock authentication for testing
	if req.Email == "" || req.Password == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	// For testing: accept any non-empty credentials
	token := generateMockToken(req.Email)
	
	// Determine role based on email
	role := "user"
	if req.Email == "admin@bookify.com" || req.Email == "admin@test.com" {
		role = "admin"
	}

	c.JSON(http.StatusOK, AuthResponse{
		Token: token,
		User: map[string]interface{}{
			"id":        "user_" + hex.EncodeToString([]byte(req.Email)[:8]),
			"email":     req.Email,
			"name":      req.Email, // Use email as name for mock
			"role":      role,
			"createdAt": time.Now().Format(time.RFC3339),
		},
	})
}

func (ah *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Email == "" || req.Password == "" || req.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing required fields"})
		return
	}

	// Mock user creation for testing
	token := generateMockToken(req.Email)

	c.JSON(http.StatusCreated, AuthResponse{
		Token: token,
		User: map[string]interface{}{
			"id":        "user_" + hex.EncodeToString([]byte(req.Email)[:8]),
			"email":     req.Email,
			"name":      req.Name,
			"role":      "user",
			"createdAt": time.Now().Format(time.RFC3339),
		},
	})
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
