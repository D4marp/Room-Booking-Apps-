# 🚀 Quick Firebase & Google Console Setup

## 📋 Your App Information

```
📦 Package Name:  com.bookify.rooms
🔐 SHA-1 Fingerprint:  3A:C5:5C:E8:7F:14:33:B7:0A:01:CC:1C:7F:1A:76:45:1E:EE:8B:08
```

---

## ⚡ 3-Step Setup (5 minutes)

### Step 1: Firebase Console Setup
```
1. Open: https://console.firebase.google.com
2. Select "bookify-rooms" project (or create new)
3. Click "Project Settings" (gear icon)
4. Go to "Your apps" tab
5. Click Android app (or add if not exists)
6. Copy this SHA-1:
   DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
7. Click "Add fingerprint"
8. Paste SHA-1
9. Save
10. Download google-services.json
11. Move to: android/app/google-services.json
```

### Step 2: Google Cloud Console
```
1. Open: https://console.cloud.google.com
2. Select "bookify-rooms" project
3. Enable APIs:
   - Search "Google Sign-In" → Enable
   - Search "Google Maps" → Enable (optional)
4. Go to "Credentials"
5. Click "Create Credentials" → "OAuth 2.0 Client ID"
6. Select "Android"
7. Enter:
   - Package Name: com.bookify.rooms
   - SHA-1: DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
8. Create
9. Copy Client ID for later
```

### Step 3: Test in Flutter App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Commands Reference

### Get SHA-1 Again
```bash
keytool -keystore ~/.android/debug.keystore -list -v -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### Get All Info
```bash
keytool -keystore ~/.android/debug.keystore -list -v -alias androiddebugkey -storepass android -keypass android
```

### Verify in App
```bash
flutter run -v | grep -i "sha\|fingerprint"
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] google-services.json in android/app/
- [ ] SHA-1 added to Firebase Console
- [ ] Google Sign-In API enabled in Google Cloud
- [ ] OAuth 2.0 credentials created
- [ ] Package name verified: com.bookify.rooms
- [ ] App runs without auth errors: `flutter run`

---

## 🎯 Next: Enable Services in App

### In pubspec.yaml (Already included)
```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.20.0
google_sign_in: ^6.2.1
```

### In main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

---

## 🔗 Quick Links

- 🔥 [Firebase Console](https://console.firebase.google.com)
- ☁️ [Google Cloud Console](https://console.cloud.google.com)
- 📚 [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- 📱 [Google Sign-In Setup](https://developers.google.com/identity/sign-in/web/sign-in)

---

**Ready to go!** 🚀
