package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/D4marp/bookify-rooms-backend/internal/config"
	"github.com/D4marp/bookify-rooms-backend/internal/handlers"
	"github.com/D4marp/bookify-rooms-backend/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Initialize config
	cfg := config.NewConfig()

	// Set Gin mode
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize services
	ctx := context.Background()

	// Firebase service
	firebaseService, err := services.NewFirebaseService(ctx, cfg)
	if err != nil {
		log.Fatalf("Failed to initialize Firebase service: %v", err)
	}
	defer firebaseService.Close()

	// Google Calendar service
	googleCalendarService, err := services.NewGoogleCalendarService(ctx, cfg)
	if err != nil {
		log.Fatalf("Failed to initialize Google Calendar service: %v", err)
	}

	// Microsoft Calendar service
	microsoftCalendarService, err := services.NewMicrosoftCalendarService(ctx, cfg)
	if err != nil {
		log.Fatalf("Failed to initialize Microsoft Calendar service: %v", err)
	}

	// Initialize Gin router
	router := gin.Default()

	// Setup routes
	setupRoutes(router, firebaseService, googleCalendarService, microsoftCalendarService)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s...", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func setupRoutes(
	router *gin.Engine,
	firebaseService *services.FirebaseService,
	googleCalendarService *services.GoogleCalendarService,
	microsoftCalendarService *services.MicrosoftCalendarService,
) {
	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Auth routes
	authHandler := handlers.NewAuthHandler(firebaseService, googleCalendarService, microsoftCalendarService)
	auth := router.Group("/auth")
	{
		auth.POST("/login", authHandler.Login)
		auth.POST("/register", authHandler.Register)
		auth.GET("/google/callback", authHandler.GoogleCallback)
		auth.GET("/microsoft/callback", authHandler.MicrosoftCallback)
	}

	// Calendar routes
	calendarHandler := handlers.NewCalendarHandler(googleCalendarService, microsoftCalendarService, firebaseService)
	calendar := router.Group("/calendar")
	{
		calendar.GET("/events", calendarHandler.GetEvents)
		calendar.POST("/events", calendarHandler.CreateEvent)
		calendar.PUT("/events/:id", calendarHandler.UpdateEvent)
		calendar.DELETE("/events/:id", calendarHandler.DeleteEvent)
	}

	// Booking routes
	bookingHandler := handlers.NewBookingHandler(firebaseService)
	booking := router.Group("/bookings")
	{
		booking.GET("", bookingHandler.GetBookings)
		booking.POST("", bookingHandler.CreateBooking)
		booking.PUT("/:id", bookingHandler.UpdateBooking)
		booking.DELETE("/:id", bookingHandler.DeleteBooking)
	}

	// Room routes
	roomHandler := handlers.NewRoomHandler(firebaseService)
	room := router.Group("/rooms")
	{
		room.GET("", roomHandler.GetRooms)
		room.GET("/:id", roomHandler.GetRoomByID)
		room.POST("", roomHandler.CreateRoom)
		room.PUT("/:id", roomHandler.UpdateRoom)
		room.DELETE("/:id", roomHandler.DeleteRoom)
	}
}
