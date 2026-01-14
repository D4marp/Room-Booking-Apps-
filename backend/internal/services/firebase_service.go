package services

import (
	"context"
	"encoding/json"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"github.com/D4marp/bookify-rooms-backend/internal/config"
	"google.golang.org/api/option"
)

type FirebaseService struct {
	client *firestore.Client
	app    *firebase.App
}

func NewFirebaseService(ctx context.Context, cfg *config.Config) (*FirebaseService, error) {
	// Create credentials JSON from config
	creds := map[string]interface{}{
		"type":                 "service_account",
		"project_id":           cfg.FirebaseProjectID,
		"private_key_id":       cfg.FirebasePrivateKeyID,
		"private_key":          cfg.FirebasePrivateKey,
		"client_email":         cfg.FirebaseClientEmail,
		"client_id":            cfg.FirebaseClientID,
		"auth_uri":             "https://accounts.google.com/o/oauth2/auth",
		"token_uri":            "https://oauth2.googleapis.com/token",
		"auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
	}

	credBytes, err := json.Marshal(creds)
	if err != nil {
		return nil, err
	}

	opt := option.WithCredentialsJSON(credBytes)
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, err
	}

	client, err := app.Firestore(ctx)
	if err != nil {
		return nil, err
	}

	return &FirebaseService{
		client: client,
		app:    app,
	}, nil
}

func (fs *FirebaseService) Close() error {
	return fs.client.Close()
}

func (fs *FirebaseService) Collection(name string) *firestore.CollectionRef {
	return fs.client.Collection(name)
}

func (fs *FirebaseService) Doc(path string) *firestore.DocumentRef {
	return fs.client.Doc(path)
}

func (fs *FirebaseService) GetDocument(ctx context.Context, path string) (*firestore.DocumentSnapshot, error) {
	return fs.client.Doc(path).Get(ctx)
}

func (fs *FirebaseService) SetDocument(ctx context.Context, path string, data interface{}) (*firestore.WriteResult, error) {
	return fs.client.Doc(path).Set(ctx, data)
}

func (fs *FirebaseService) UpdateDocument(ctx context.Context, path string, updates []firestore.Update) (*firestore.WriteResult, error) {
	return fs.client.Doc(path).Update(ctx, updates)
}

func (fs *FirebaseService) DeleteDocument(ctx context.Context, path string) (*firestore.WriteResult, error) {
	return fs.client.Doc(path).Delete(ctx)
}

func (fs *FirebaseService) Query(collection string) firestore.Query {
	return fs.client.Collection(collection).Query
}
