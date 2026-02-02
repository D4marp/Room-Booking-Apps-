package services

import (
	"context"
	"io/ioutil"
	"os"

	"github.com/D4marp/bookify-rooms-backend/internal/config"
	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

type GoogleCalendarService struct {
	service *calendar.Service
	config  *oauth2.Config
	cfg     *config.Config
}

func NewGoogleCalendarService(ctx context.Context, cfg *config.Config) (*GoogleCalendarService, error) {
	// Load credentials from file
	credFile := cfg.GoogleCalendarCredentials
	credBytes, err := ioutil.ReadFile(credFile)
	if err != nil {
		// Try to create from env variables
		credBytes = []byte(cfg.GoogleCalendarCredentials)
	}

	config, err := google.ConfigFromJSON(credBytes, calendar.CalendarScope)
	if err != nil {
		return nil, err
	}

	config.RedirectURL = cfg.GoogleCalendarRedirectURL

	// Create service with default credentials
	var opt option.ClientOption
	if cfg.GoogleCalendarCredentials != "" && os.Getenv("GOOGLE_APPLICATION_CREDENTIALS") == "" {
		opt = option.WithCredentialsFile(cfg.GoogleCalendarCredentials)
	}

	service, err := calendar.NewService(ctx, opt)
	if err != nil {
		return nil, err
	}

	return &GoogleCalendarService{
		service: service,
		config:  config,
		cfg:     cfg,
	}, nil
}

func (gcs *GoogleCalendarService) GetAuthURL() string {
	return gcs.config.AuthCodeURL("state", oauth2.AccessTypeOffline)
}

func (gcs *GoogleCalendarService) GetTokenFromCode(ctx context.Context, code string) (*oauth2.Token, error) {
	return gcs.config.Exchange(ctx, code)
}

func (gcs *GoogleCalendarService) ListEvents(ctx context.Context, calendarID string) ([]*calendar.Event, error) {
	events, err := gcs.service.Events.List(calendarID).Do()
	if err != nil {
		return nil, err
	}
	return events.Items, nil
}

func (gcs *GoogleCalendarService) CreateEvent(ctx context.Context, calendarID string, event *calendar.Event) (*calendar.Event, error) {
	return gcs.service.Events.Insert(calendarID, event).Do()
}

func (gcs *GoogleCalendarService) UpdateEvent(ctx context.Context, calendarID, eventID string, event *calendar.Event) (*calendar.Event, error) {
	return gcs.service.Events.Update(calendarID, eventID, event).Do()
}

func (gcs *GoogleCalendarService) DeleteEvent(ctx context.Context, calendarID, eventID string) error {
	return gcs.service.Events.Delete(calendarID, eventID).Do()
}

func (gcs *GoogleCalendarService) GetCalendars(ctx context.Context) ([]*calendar.CalendarListEntry, error) {
	calendars, err := gcs.service.CalendarList.List().Do()
	if err != nil {
		return nil, err
	}
	return calendars.Items, nil
}
