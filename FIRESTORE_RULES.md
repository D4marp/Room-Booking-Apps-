# Firestore Security Rules Setup

## ⚠️ Problem
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

This happens because **Firestore security rules don't allow reading bookings**. 

## ✅ Solution: Update Firestore Security Rules

### Step-by-Step Guide:

#### 1️⃣ Open Firebase Console
- Go to [Firebase Console](https://console.firebase.google.com)
- Select your project
- Navigate to **Firestore Database** (left sidebar)

#### 2️⃣ Click on "Rules" Tab
At the top of the Firestore Database page, click the **Rules** tab

#### 3️⃣ Replace Rules with This Code
Delete all existing rules and paste the following:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - only user can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Rooms collection - all authenticated users can read
    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
    
    // Bookings collection - authenticated users can read all, create own, update own
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

#### 4️⃣ Click "Publish"
Click the **Publish** button to apply the new rules

#### 5️⃣ Test in App
- Hot restart the app (or rebuild)
- Navigate to a room and click "Book Now"
- Schedule should now load properly
- Booking should save to Firestore successfully

---

## 🔐 What These Rules Allow:

| Action | Allowed | Notes |
|--------|---------|-------|
| ✅ Read Bookings | Authenticated users | Can see all bookings |
| ✅ Create Booking | Authenticated users | Must use own userId |
| ✅ Edit Own Booking | User who created it | Only own booking |
| ✅ Delete Own Booking | User who created it | Only own booking |
| ✅ Read Rooms | Authenticated users | Can see all rooms |
| ✅ Write Rooms | Admin only | Admin token required |
| ✅ Read User Profile | Own user only | Privacy protected |

---

## 🧪 Verification Checklist

After publishing rules, verify:
- [ ] App doesn't show "Permission Denied" error
- [ ] Schedule loads properly in RoomDetailsScreen
- [ ] "Book Now" button works
- [ ] Bookings appear in Firestore console under `/bookings` collection
- [ ] Debug console shows: `✅ Booking saved successfully to Firestore`

---

## 🐛 If Still Not Working:

1. **Check Firestore Console** → Make sure rules are published (should show green checkmark)
2. **Check user authentication** → Verify user is logged in
3. **Check network** → Verify device has internet connection
4. **Rebuild app** → Do full rebuild, not just hot restart:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
5. **Check Firebase project** → Verify project ID matches in `google-services.json`/`GoogleService-Info.plist`

---

## 📱 Expected Behavior After Setup

**Before Setup:**
```
❌ Error fetching bookings for room...
⚠️ Permission denied! Check Firestore security rules.
```

**After Setup:**
```
✅ Booking saved successfully to Firestore
📅 RoomDetailsScreen: Loaded 1 bookings for room fzjyGq62qx3gQeDZ0s23
```

