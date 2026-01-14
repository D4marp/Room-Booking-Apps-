# Flutter to Golang Backend Migration

## Overview
Migration dari Firebase backend ke Golang backend API dengan integrasi Google Calendar dan Microsoft Calendar.

## Changes Summary

### 1. API Layer
- **New:** `lib/utils/api_config.dart` - API configuration & endpoints
- **New:** `lib/services/api_service.dart` - HTTP client service untuk Golang backend

### 2. State Management (Providers)
Menggunakan versi baru yang support Golang backend:
- **New:** `lib/providers/auth_provider_v2.dart` - Authentication dengan API
- **New:** `lib/providers/room_provider_v2.dart` - Room management dengan API
- **New:** `lib/providers/booking_provider_v2.dart` - Booking management dengan API

### 3. UI - Admin CMS (3 Views)
Aplikasi sekarang memiliki 3 view utama:

#### a) User View (Home)
- Lihat daftar ruangan
- Buat booking
- Kelola booking pribadi

#### b) Room View (Room Management)
- Lihat semua ruangan dengan detail
- Filter dan search
- Lihat ketersediaan

#### c) Admin CMS View (New)
Sistem CMS lengkap untuk admin dengan 3 subview:

**1. Admin Rooms CMS** (`admin_rooms_cms_screen.dart`)
- Tambah ruangan baru
- Edit informasi ruangan
- Hapus ruangan
- Lihat daftar ruangan dalam tabel

**2. Admin Bookings CMS** (`admin_bookings_cms_screen.dart`)
- Lihat semua booking
- Approve/reject booking
- Cancel booking
- Monitor status booking

**3. Admin Users CMS** (`admin_users_cms_screen.dart`)
- Kelola user (coming soon)

### 4. Main Navigation
- **New:** `lib/screens/main_navigation_screen.dart` - Main navigation dengan 3 tab

## API Endpoints

### Authentication
- `POST /auth/login` - Login
- `POST /auth/register` - Register
- `GET /auth/google/callback` - Google OAuth callback
- `GET /auth/microsoft/callback` - Microsoft OAuth callback

### Rooms
- `GET /rooms` - List semua ruangan
- `GET /rooms/:id` - Get ruangan spesifik
- `POST /rooms` - Buat ruangan baru (admin only)
- `PUT /rooms/:id` - Update ruangan (admin only)
- `DELETE /rooms/:id` - Hapus ruangan (admin only)

### Bookings
- `GET /bookings` - List booking
- `POST /bookings` - Buat booking baru
- `PUT /bookings/:id` - Update booking
- `DELETE /bookings/:id` - Hapus booking

### Calendar
- `GET /calendar/events` - List events
- `POST /calendar/events` - Buat event
- `PUT /calendar/events/:id` - Update event
- `DELETE /calendar/events/:id` - Hapus event

## Configuration

### Environment Setup
Dalam `lib/utils/api_config.dart`:
```dart
static const String baseUrl = 'http://localhost:8080';
```

Ubah ke URL production sesuai kebutuhan.

### Dependencies
Tambahkan package baru di `pubspec.yaml`:
- `http: ^1.1.0` - HTTP client

## Migration Steps

1. **Backend Setup**
   ```bash
   cd backend
   go mod download
   cp .env.example .env
   # Edit .env dengan credentials
   go run ./cmd/main.go
   ```

2. **Flutter Setup**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Update API Base URL** (jika berbeda dari localhost:8080)
   Edit `lib/utils/api_config.dart`

## File Structure

```
lib/
├── providers/
│   ├── auth_provider_v2.dart      # New - Golang backend
│   ├── room_provider_v2.dart      # New - Golang backend
│   ├── booking_provider_v2.dart   # New - Golang backend
│   └── (old files tetap untuk backward compatibility)
├── services/
│   ├── api_service.dart           # New - HTTP client
│   └── (old Firebase services tetap)
├── screens/
│   ├── admin/
│   │   ├── admin_cms_screen.dart                # New - Main CMS
│   │   ├── admin_rooms_cms_screen.dart          # New - Rooms CMS
│   │   ├── admin_bookings_cms_screen.dart       # New - Bookings CMS
│   │   ├── admin_users_cms_screen.dart          # New - Users CMS
│   │   └── (old files tetap)
│   ├── main_navigation_screen.dart  # New - 3 view navigation
│   └── (existing screens)
├── utils/
│   ├── api_config.dart            # New - API config
│   └── (existing utils)
└── main_v2.dart                   # New - Updated main

```

## Features

### Authentication
- Login dengan email/password
- Register user baru
- Support OAuth 2.0 (Google, Microsoft)
- Token-based authentication

### Admin CMS
- ✅ Room management (CRUD)
- ✅ Booking management (view, approve, cancel)
- 🔄 User management (coming soon)
- 🔄 Reports & Analytics (future)

### Calendar Integration
- Google Calendar sync
- Microsoft Calendar (Outlook) sync
- Auto-sync booking ke calendar

### Role-based Access
- `user` - Akses Home & Rooms view
- `admin` - Akses Admin CMS view

## Notes

### Firebase Legacy Code
- File Firebase lama tetap ada untuk backward compatibility
- Tidak perlu dihapus sekarang, hanya tidak digunakan
- Bisa di-remove nanti saat full migration selesai

### Future Improvements
1. Persistent token storage (shared_preferences)
2. Offline support dengan caching
3. Real-time updates dengan WebSocket
4. Dashboard analytics untuk admin
5. User management CMS

## Troubleshooting

### API Connection Error
- Cek API base URL di `api_config.dart`
- Pastikan Golang backend sudah running
- Check firewall/CORS settings

### Authentication Error
- Pastikan credentials benar
- Clear app cache dan login ulang
- Check backend logs untuk error detail

### Admin Access Denied
- Pastikan user memiliki role 'admin'
- Check backend database user role

