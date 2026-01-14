# Bookify Rooms - Golang Backend

Backend API untuk Room Booking System dengan integrasi Google Calendar dan Microsoft Calendar (Outlook).

## Features

- 🔐 Firebase Authentication
- 📅 Google Calendar Integration
- 📅 Microsoft Calendar (Outlook) Integration
- 🏢 Room Management
- 📋 Booking Management
- 🔄 Real-time Sync between Bookings and Calendars
- 🐳 Docker Support

## Prerequisites

- Go 1.21 or higher
- Docker & Docker Compose (optional)
- Firebase Project
- Google Calendar API Credentials
- Microsoft Graph API Credentials

## Installation

### 1. Clone Repository
```bash
cd backend
```

### 2. Install Dependencies
```bash
go mod download
go mod tidy
```

### 3. Setup Environment Variables
```bash
cp .env.example .env
# Edit .env with your credentials
```

### 4. Run Backend

**Development Mode (with hot reload):**
```bash
make dev
# or
go run ./cmd/main.go
```

**Production Mode:**
```bash
make build
make run
```

### 5. Access API
```
http://localhost:8080
```

## API Endpoints

### Health Check
- `GET /health` - Health check

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /auth/google/callback` - Google OAuth callback
- `GET /auth/microsoft/callback` - Microsoft OAuth callback

### Calendar
- `GET /calendar/events` - Get calendar events
- `POST /calendar/events` - Create event
- `PUT /calendar/events/:id` - Update event
- `DELETE /calendar/events/:id` - Delete event

### Bookings
- `GET /bookings` - Get all bookings
- `POST /bookings` - Create booking
- `PUT /bookings/:id` - Update booking
- `DELETE /bookings/:id` - Delete booking

### Rooms
- `GET /rooms` - Get all rooms
- `GET /rooms/:id` - Get room by ID
- `POST /rooms` - Create room
- `PUT /rooms/:id` - Update room
- `DELETE /rooms/:id` - Delete room

## Docker Setup

### Build Image
```bash
docker build -t bookify-rooms-backend:latest .
```

### Run Container
```bash
docker run -p 8080:8080 --env-file .env bookify-rooms-backend:latest
```

### Using Docker Compose
```bash
docker-compose up -d
```

## Project Structure

```
backend/
├── cmd/
│   └── main.go              # Entry point
├── internal/
│   ├── config/              # Configuration
│   ├── handlers/            # HTTP handlers
│   ├── models/              # Data models
│   └── services/            # Business logic
├── pkg/                     # Reusable packages
├── go.mod                   # Dependencies
├── Dockerfile               # Docker build
├── docker-compose.yml       # Docker compose
├── Makefile                 # Build commands
└── README.md
```

## Environment Variables

See `.env.example` for all required environment variables:

- `FIREBASE_*` - Firebase credentials
- `GOOGLE_CALENDAR_*` - Google Calendar API
- `MICROSOFT_*` - Microsoft Graph API
- `JWT_SECRET` - JWT token secret

## Development

### Run Tests
```bash
go test -v ./...
```

### Format Code
```bash
go fmt ./...
go vet ./...
```

### Install/Update Dependencies
```bash
go get -u <package-name>
go mod tidy
```

## Calendar Integration

### Google Calendar
- Uses OAuth 2.0 for authentication
- Supports multiple calendars
- Auto-sync bookings to calendar

### Microsoft Calendar (Outlook)
- Uses Azure AD for authentication
- Supports Microsoft Graph API
- Auto-sync bookings to Outlook

## Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -am 'Add your feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Open Pull Request

## License

MIT

## Support

For issues and questions, please open an issue in the repository.
