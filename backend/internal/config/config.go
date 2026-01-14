package config

import (
	"os"
)

type Config struct {
	// Server
	Port string
	Env  string

	// Firebase
	FirebaseProjectID      string
	FirebasePrivateKeyID   string
	FirebasePrivateKey     string
	FirebaseClientEmail    string
	FirebaseClientID       string

	// Google Calendar
	GoogleCalendarCredentials string
	GoogleCalendarRedirectURL string

	// Microsoft Calendar
	MicrosoftClientID     string
	MicrosoftClientSecret string
	MicrosoftRedirectURL  string
	MicrosoftTenantID     string

	// JWT
	JWTSecret string

	// Database
	DatabaseURL string
}

func NewConfig() *Config {
	return &Config{
		Port:                      getEnv("PORT", "8080"),
		Env:                       getEnv("ENV", "development"),
		FirebaseProjectID:         getEnv("FIREBASE_PROJECT_ID", ""),
		FirebasePrivateKeyID:      getEnv("FIREBASE_PRIVATE_KEY_ID", ""),
		FirebasePrivateKey:        getEnv("FIREBASE_PRIVATE_KEY", ""),
		FirebaseClientEmail:       getEnv("FIREBASE_CLIENT_EMAIL", ""),
		FirebaseClientID:          getEnv("FIREBASE_CLIENT_ID", ""),
		GoogleCalendarCredentials: getEnv("GOOGLE_CALENDAR_CREDENTIALS", ""),
		GoogleCalendarRedirectURL: getEnv("GOOGLE_CALENDAR_REDIRECT_URL", "http://localhost:8080/auth/google/callback"),
		MicrosoftClientID:         getEnv("MICROSOFT_CLIENT_ID", ""),
		MicrosoftClientSecret:     getEnv("MICROSOFT_CLIENT_SECRET", ""),
		MicrosoftRedirectURL:      getEnv("MICROSOFT_REDIRECT_URL", "http://localhost:8080/auth/microsoft/callback"),
		MicrosoftTenantID:         getEnv("MICROSOFT_TENANT_ID", "common"),
		JWTSecret:                 getEnv("JWT_SECRET", "your-secret-key"),
		DatabaseURL:               getEnv("DATABASE_URL", ""),
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
