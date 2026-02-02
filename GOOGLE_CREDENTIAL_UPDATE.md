# Google Calendar Credential Configuration - Updated

## 📋 Credential Information

**Project ID**: `supple-defender-484604-g1`
**Client ID**: `983929392000-a64dbck056gmr86n75go6qeaglv814k7.apps.googleusercontent.com`

### Android OAuth 2.0 Configuration
- **Package Name**: `com.bookify.rooms`
- **SHA-1 Fingerprint**: `3A:C5:5C:E8:7F:14:33:B7:0A:01:CC:1C:7F:1A:76:45:1E:EE:8B:08` (NEW)
- **Application Type**: Android

## ✅ Setup Checklist

### 1️⃣ Backend Configuration
- [x] Update `.env` file dengan Google Client ID
- [x] Update `.env` file dengan Google Client Secret
- [x] Update `google_calendar_handler.go` dengan redirect URL baru
- [ ] Set `GOOGLE_CLIENT_SECRET` value in `.env`
- [ ] Verify backend credentials

### 2️⃣ Google Cloud Console
- [ ] Register new OAuth 2.0 Client with:
  - Package Name: `com.bookify.rooms`
  - SHA-1: `3A:C5:5C:E8:7F:14:33:B7:0A:01:CC:1C:7F:1A:76:45:1E:EE:8B:08`
- [ ] Enable Google Calendar API
- [ ] Download credentials JSON

### 3️⃣ Firebase Console
- [ ] Add new SHA-1 fingerprint to Firebase
- [ ] Download updated `google-services.json`
- [ ] Place in `android/app/`

### 4️⃣ Flutter App
- [ ] Update `pubspec.yaml` if needed
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`

### 5️⃣ Android Build
- [ ] Build APK: `flutter build apk --release`
- [ ] Test Google Calendar integration

## 🔑 Files Updated

1. `backend/.env` - Added new Google credentials
2. `backend/internal/handlers/google_calendar_handler.go` - Updated config
3. `SHA1_FINGERPRINT.md` - Updated with new fingerprint
4. `FIREBASE_GOOGLE_SETUP.md` - Updated with new fingerprint

## 📌 Environment Variables

```env
# Google Calendar API
GOOGLE_CLIENT_ID=983929392000-a64dbck056gmr86n75go6qeaglv814k7.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=<set-this-value>
GOOGLE_CALENDAR_REDIRECT_URL=http://localhost:8080/auth/google/callback
GOOGLE_CALENDAR_CREDENTIALS=/path/to/client_secret_983929392000-a64dbck056gmr86n75go6qeaglv814k7.apps.googleusercontent.com.json

# Android Configuration
ANDROID_SHA1_FINGERPRINT=3A:C5:5C:E8:7F:14:33:B7:0A:01:CC:1C:7F:1A:76:45:1E:EE:8B:08
ANDROID_PACKAGE_NAME=com.bookify.rooms
```

## 🚀 Next Steps

1. **Register OAuth Client on Google Cloud Console**
   - Go to https://console.cloud.google.com
   - Select project: `supple-defender-484604-g1`
   - Go to APIs & Services → Credentials
   - Create new Android OAuth 2.0 Client with above package name and SHA-1

2. **Update GOOGLE_CLIENT_SECRET**
   - After creating the client, get the client secret
   - Add to `backend/.env`

3. **Download Configuration Files**
   - Download `client_secret_*.json` from Google Console
   - Place in backend directory

4. **Test the Connection**
   - Run backend: `make run`
   - Test with Postman or curl

## 📚 References

- [Google Calendar API Quickstart](https://developers.google.com/calendar/api/quickstart/go)
- [OAuth 2.0 for Android](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Android Signing Documentation](https://developer.android.com/studio/publish/app-signing)
