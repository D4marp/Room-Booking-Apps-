# SHA-1 Certificate Fingerprint for Android App

## 📱 App Certificate Information

### Debug Keystore (Development)
```
Keystore Path:  ~/.android/debug.keystore
Alias:          androiddebugkey
Store Password: android
Key Password:   android
```

### 🔐 SHA-1 Fingerprint (DEBUG) - UPDATED
```
3A:C5:5C:E8:7F:14:33:B7:0A:01:CC:1C:7F:1A:76:45:1E:EE:8B:08
```

### SHA-256 Fingerprint (DEBUG) - UPDATED
```
(To be updated after full build)
```

---

## 🤔 Apa itu Certificate Fingerprint?

**Certificate Fingerprint** adalah hash unik dari certificate signing yang digunakan untuk:
- ✅ Firebase Authentication
- ✅ Google Sign-In
- ✅ Google Maps API
- ✅ App Linking
- ✅ OAuth 2.0

---

## 🚀 Cara Menggunakan Fingerprint

### 1️⃣ **Untuk Firebase**

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Select project Anda
3. Go to **Project Settings** → **Your apps**
4. Select Android app
5. Click **Add fingerprint**
6. Paste SHA-1 fingerprint:
   ```
   DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
   ```
7. Save

### 2️⃣ **Untuk Google Sign-In**

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Select project Anda
3. Go to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID** → **Android**
5. Enter Package Name: `com.bookify.rooms`
6. Enter SHA-1 Fingerprint:
   ```
   DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
   ```
7. Create

### 3️⃣ **Untuk Google Maps API**

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Go to **APIs & Services** → **Credentials**
3. Click **Create Credentials** → **API Key**
4. Restrict to Android apps
5. Add package name: `com.bookify.rooms`
6. Add SHA-1 fingerprint:
   ```
   DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
   ```

---

## 📋 Perintah untuk Mendapatkan Fingerprint

### Debug Keystore
```bash
keytool -keystore ~/.android/debug.keystore \
  -list -v \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

### Production Keystore
```bash
keytool -keystore /path/to/your/keystore.jks \
  -list -v \
  -alias your_alias \
  -storepass your_storepass \
  -keypass your_keypass
```

### Hanya SHA-1 Fingerprint
```bash
keytool -keystore ~/.android/debug.keystore \
  -list -v \
  -alias androiddebugkey \
  -storepass android \
  -keypass android | grep "SHA1:"
```

**Output:**
```
SHA1: DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
```

---

## ⚠️ Penting: Debug vs Production

| Aspek | Debug | Production |
|-------|-------|-----------|
| **Fingerprint** | Dari ~/.android/debug.keystore | Dari production keystore |
| **Untuk** | Development & Testing | Live app di Play Store |
| **Berbeda?** | Ya, harus berbeda | Harus tersimpan aman |
| **Firebase** | Harus add di Firebase | Harus add di Firebase |
| **Google** | Harus add di Google Cloud | Harus add di Google Cloud |

### ⚠️ JANGAN LUPAKAN
Ketika membuat production app:
1. Generate production keystore dengan keytool
2. Extract SHA-1 dari production keystore
3. Add production SHA-1 ke Firebase & Google Cloud
4. Update build.gradle.kts dengan production keystore config

---

## 🔧 Setup untuk Project Ini

### Package Name
```
com.bookify.rooms
```

### Debug SHA-1 Fingerprint
```
DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
```

### Langkah-langkah Setup

#### 1. Firebase Console
```
1. Go to firebase.google.com
2. Create/Select project
3. Add Android app
4. Package Name: com.bookify.rooms
5. SHA-1: DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
6. Download google-services.json
7. Place in: android/app/
```

#### 2. Google Cloud Console
```
1. Go to console.cloud.google.com
2. Enable APIs:
   - Google Sign-In API
   - Google Maps API
   - Calendar API (optional)
3. Create OAuth 2.0 credentials for Android
4. Enter:
   - Package Name: com.bookify.rooms
   - SHA-1: DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D
```

#### 3. Android Build Configuration
```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.bookify.rooms"
    
    defaultConfig {
        applicationId = "com.bookify.rooms"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

---

## 📱 Verifikasi di Aplikasi

Untuk mengecek fingerprint yang digunakan oleh app:

### Dari Logcat (saat build)
```bash
flutter run -v | grep -i "sha\|fingerprint"
```

### Dari Build Output
```bash
flutter build apk -v | grep -i "sha\|fingerprint"
```

---

## 🆘 Troubleshooting

### Error: "keytool not found"
```bash
# macOS/Linux
export PATH=$PATH:$JAVA_HOME/bin

# or add to ~/.bashrc or ~/.zshrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.zshrc
```

### Error: "Keystore was tampered with"
```bash
# Regenerate debug keystore
rm ~/.android/debug.keystore
keytool -genkey -v -keystore ~/.android/debug.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias androiddebugkey \
  -storepass android \
  -keypass android \
  -dname "CN=Android Debug,O=Android,C=US"
```

### Firebase: "SHA-1 fingerprint mismatch"
1. Verify SHA-1 dari keytool matches Firebase
2. Make sure app package name matches
3. Clean and rebuild: `flutter clean && flutter pub get && flutter run`

---

## 📝 Checklist

- [ ] Get SHA-1 fingerprint dari debug keystore ✅
- [ ] Add SHA-1 ke Firebase Console
- [ ] Add SHA-1 ke Google Cloud Console
- [ ] Download google-services.json
- [ ] Place google-services.json di android/app/
- [ ] Verify package name di build.gradle.kts
- [ ] Test Firebase authentication
- [ ] Test Google Sign-In
- [ ] Create production keystore untuk release

---

## 🔒 Security Notes

### Debug Keystore
- ✅ Can share for team development
- ✅ Safe (not used in production)
- ✅ Default password: android

### Production Keystore
- ❌ NEVER share publicly
- ❌ NEVER commit to Git
- ❌ Keep in secure location
- ❌ Different password required

---

## 📚 Resources

- [Android Keystore Documentation](https://developer.android.com/training/articles/keystore)
- [Firebase Console](https://console.firebase.google.com)
- [Google Cloud Console](https://console.cloud.google.com)
- [Flutter Android Setup](https://flutter.dev/docs/get-started/install/linux#android-setup)

---

**Generated:** January 15, 2026  
**Package Name:** com.bookify.rooms  
**Debug SHA-1:** DD:21:4A:17:C7:B1:B7:93:1D:6A:BD:6A:4D:61:5D:1F:31:62:94:0D  
**Status:** ✅ Ready for Firebase & Google Console Setup
