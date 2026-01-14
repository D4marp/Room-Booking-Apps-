package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/D4marp/bookify-rooms-backend/internal/config"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/microsoft"
)

type MicrosoftCalendarService struct {
	config     *oauth2.Config
	httpClient *http.Client
	cfg        *config.Config
}

type MicrosoftEvent struct {
	ID       string `json:"id"`
	Subject  string `json:"subject"`
	Start    struct {
		DateTime string `json:"dateTime"`
		TimeZone string `json:"timeZone"`
	} `json:"start"`
	End struct {
		DateTime string `json:"dateTime"`
		TimeZone string `json:"timeZone"`
	} `json:"end"`
	BodyPreview string `json:"bodyPreview"`
	Organizer   struct {
		EmailAddress struct {
			Name    string `json:"name"`
			Address string `json:"address"`
		} `json:"emailAddress"`
	} `json:"organizer"`
}

func NewMicrosoftCalendarService(ctx context.Context, cfg *config.Config) (*MicrosoftCalendarService, error) {
	config := &oauth2.Config{
		ClientID:     cfg.MicrosoftClientID,
		ClientSecret: cfg.MicrosoftClientSecret,
		RedirectURL:  cfg.MicrosoftRedirectURL,
		Scopes: []string{
			"Calendars.ReadWrite",
		},
		Endpoint: microsoft.AzureADEndpoint(cfg.MicrosoftTenantID),
	}

	return &MicrosoftCalendarService{
		config: config,
		cfg:    cfg,
	}, nil
}

func (mcs *MicrosoftCalendarService) GetAuthURL() string {
	return mcs.config.AuthCodeURL("state", oauth2.AccessTypeOffline)
}

func (mcs *MicrosoftCalendarService) GetTokenFromCode(ctx context.Context, code string) (*oauth2.Token, error) {
	return mcs.config.Exchange(ctx, code)
}

func (mcs *MicrosoftCalendarService) ListEvents(ctx context.Context, accessToken string) ([]MicrosoftEvent, error) {
	client := mcs.config.Client(ctx, &oauth2.Token{AccessToken: accessToken})
	
	resp, err := client.Get("https://graph.microsoft.com/v1.0/me/calendarview")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var result struct {
		Value []MicrosoftEvent `json:"value"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, err
	}

	return result.Value, nil
}

func (mcs *MicrosoftCalendarService) CreateEvent(ctx context.Context, accessToken string, event MicrosoftEvent) (*MicrosoftEvent, error) {
	client := mcs.config.Client(ctx, &oauth2.Token{AccessToken: accessToken})

	eventJSON, err := json.Marshal(event)
	if err != nil {
		return nil, err
	}

	resp, err := client.Post(
		"https://graph.microsoft.com/v1.0/me/events",
		"application/json",
		bytes.NewBuffer(eventJSON),
	)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("failed to create event: %s", string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var createdEvent MicrosoftEvent
	if err := json.Unmarshal(body, &createdEvent); err != nil {
		return nil, err
	}

	return &createdEvent, nil
}

func (mcs *MicrosoftCalendarService) UpdateEvent(ctx context.Context, accessToken, eventID string, event MicrosoftEvent) (*MicrosoftEvent, error) {
	client := mcs.config.Client(ctx, &oauth2.Token{AccessToken: accessToken})

	eventJSON, err := json.Marshal(event)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(
		http.MethodPatch,
		fmt.Sprintf("https://graph.microsoft.com/v1.0/me/events/%s", eventID),
		bytes.NewBuffer(eventJSON),
	)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var updatedEvent MicrosoftEvent
	if err := json.Unmarshal(body, &updatedEvent); err != nil {
		return nil, err
	}

	return &updatedEvent, nil
}

func (mcs *MicrosoftCalendarService) DeleteEvent(ctx context.Context, accessToken, eventID string) error {
	client := mcs.config.Client(ctx, &oauth2.Token{AccessToken: accessToken})

	req, err := http.NewRequest(
		http.MethodDelete,
		fmt.Sprintf("https://graph.microsoft.com/v1.0/me/events/%s", eventID),
		nil,
	)
	if err != nil {
		return err
	}

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to delete event: %s", string(body))
	}

	return nil
}
