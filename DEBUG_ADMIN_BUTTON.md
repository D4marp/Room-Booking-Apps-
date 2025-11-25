# 🔍 Debug: Admin Button Tidak Muncul

## ❓ Apa Masalahnya?

Login sebagai admin tapi admin button tidak muncul di home screen.

---

## 🎯 Lokasi Admin Button (Seharusnya Muncul)

```
Home Screen (Top-Right)
┌─────────────────────────────────┐
│  Hello Admin! 👋                 │
│                                  │
│              [📊] [👨‍💼] [👤]       │
│              Tab  Admin Profile
└─────────────────────────────────┘
```

Admin button **seharusnya di antara Tab View dan Profile**

---

## 🔧 Root Cause Analysis

Admin button tidak muncul karena salah satu:

### **1. `userModel` tidak loaded** ❌
```
authProvider.userModel = null
→ authProvider.userModel?.isAdmin = false (by default)
→ Admin button hidden
```

### **2. `isAdmin` false meski role = "admin"** ❌
```
role field di Firestore salah format
→ UserModel.isAdmin = false
→ Admin button hidden
```

### **3. Security rules belum publish** ❌
```
Firebase Firestore dalam production mode
→ Tidak bisa baca user document
→ getUserDocument() fail
→ userModel = null
→ Admin button hidden
```

---

## ✅ Solution - Debug & Fix

### **STEP 1: Check Console Log**

1. **Run app dengan debug:**
   ```bash
   flutter run -v
   ```

2. **Login sebagai admin**

3. **Lihat console untuk error message:**
   - Cari text: `Error`, `exception`, `permission`
   - Screenshot error yang keluar

### **STEP 2: Check Firestore User Document**

1. Firebase Console
2. Firestore Database → Collections → **users**
3. Cari admin user document (berdasarkan email)
4. **Check field `role`:**
   ```
   role: "admin"  ✅ Benar
   role: admin    ❌ Salah (harus string)
   role: "Admin"  ❌ Salah (harus lowercase)
   role: (tidak ada) ❌ Tidak ada
   ```

**Jika salah:**
- Edit document
- Update field `role` ke `"admin"` (lowercase string)
- Save

### **STEP 3: Publish Security Rules**

**CRITICAL:** Jika belum, jangan lanjut!

1. Firebase Console → Firestore → **Rules tab**
2. Copy dari `FIREBASE_SETUP_STEPS.md`
3. Paste semua code
4. Click **Publish** ✅
5. **Tunggu green checkmark muncul**

### **STEP 4: Restart App & Login Ulang**

1. Stop app: `Ctrl+C`
2. Clear cache: `flutter clean`
3. Run app: `flutter run`
4. **Logout**
5. **Login ulang dengan admin account**
6. **Check admin button** (seharusnya muncul sekarang!)

---

## 📋 Checklist Debug

```
[ ] Run app dengan flutter run -v
[ ] Login as admin
[ ] Check console untuk error message (screenshot!)
[ ] Buka Firebase Console
[ ] Lihat user document di Firestore
[ ] Verify role field = "admin" (lowercase string)
[ ] Jika tidak ada role field: add manually
[ ] Publish security rules (check green checkmark)
[ ] Stop & restart app
[ ] flutter clean
[ ] flutter run
[ ] Logout & login ulang
[ ] Admin button seharusnya muncul sekarang!
```

---

## 🧪 Test Setelah Fix

### **Admin Button Muncul?**

**YA ✅ → Admin Panel Siap**
- Click admin button
- Go to STEP 4 (Add Room)

**TIDAK ❌ → Check dibawah:**

---

## ❌ Troubleshooting Lanjutan

### **Error: "Permission denied" di console**

**Cause:** Security rules tidak publish atau salah format

**Fix:**
1. Firebase Console → Firestore → Rules
2. Copy rules dari `FIREBASE_SETUP_STEPS.md` **LENGKAP**
3. Verify struktur:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // ... rules ...
     }
   }
   ```
4. Click Publish

### **Error: "Cannot read field 'role'"**

**Cause:** User document tidak ada atau field berbeda

**Fix:**
1. Firebase → Firestore → users collection
2. Verify user document exists
3. Add/update field:
   ```
   role (string) = "admin"
   ```

### **userModel masih null setelah login**

**Cause:** Auth state listener tidak working

**Fix:**
1. Stop app
2. flutter clean
3. flutter run
4. Login ulang

### **Still tidak muncul?**

**Lakukan:**
1. Screenshot console output (error message)
2. Screenshot Firestore user document
3. Screenshot Firebase Rules tab
4. Kirim ke saya (akan lebih mudah debug)

---

## 🚀 Next Step (Setelah Admin Button Muncul)

Jika admin button **SUDAH MUNCUL:**

1. Click admin button (👨‍💼)
2. Go to `ADD_ROOM_GUIDE.md`
3. Follow STEP 1: Click + button to add room

---

**Send screenshot & error message jika masih stuck!** 📸
