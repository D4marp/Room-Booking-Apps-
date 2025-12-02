# Firestore Security Rules Setup

## Issue
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Solution: Update Firestore Security Rules

Go to **Firebase Console** → **Firestore Database** → **Rules** and replace with:

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

## Steps:
1. Open [Firebase Console](https://console.firebase.google.com)
2. Go to your project → Firestore Database
3. Click on **Rules** tab
4. Replace entire content with rules above
5. Click **Publish**
6. Test in app (should work now!)

## What these rules allow:
✅ Authenticated users can read all bookings
✅ Users can create bookings (auto-assigned to their userId)
✅ Users can only modify their own bookings
✅ Admin can modify rooms
✅ All authenticated users can read rooms
