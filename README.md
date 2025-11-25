# RoomBooking - Office & Campus Room Booking System

A free Flutter application for office and campus room booking with Firebase backend, featuring modern UI design, time-slot management, and real-time booking system.

## 🚀 Features

### Core Functionality
- **User Authentication**: Email/Password authentication with role-based access control
- **Admin Panel**: Full CRUD operations for managing rooms
- **Room Browsing**: Beautiful room listings with search and filter
- **Room Tab View**: View all rooms in separate tabs for easy comparison
- **Office/Campus Focused**: Purpose-based bookings for meetings, classes, training, etc.
- **Booking System**: Date selection, guest count, price calculation
- **Payment Integration**: Razorpay payment gateway
- **Booking Management**: View and manage bookings history
- **User Profile**: Profile management and settings
- **Real-time Status**: Live availability status (Available/Booked) for all rooms

### Admin Features
- **Room Management**: Add, edit, and delete rooms
- **Availability Control**: Toggle room availability status
- **Room Details**: Manage room name, description, class, price, capacity, location, and images
- **Dashboard**: View all rooms with their current booking status
- **Role-Based Access**: Admin panel only accessible to admin users

### Technical Features
- **Firebase Backend**: Authentication, Firestore, Storage
- **State Management**: Provider pattern
- **Modern UI**: Material Design 3 with custom blue gradient theme
- **Responsive Design**: Works on all screen sizes
- **Error Handling**: Comprehensive error handling throughout
- **Animations**: Smooth transitions and loading states

## 🎨 Design System

### Color Palette
- **Primary Blue**: #2563EB (Modern blue for CTAs)
- **Secondary Blue**: #1E40AF (Darker blue for accents)
- **Cream Background**: #FEF7ED (Warm background)
- **Success Green**: #10B981 (Success states)
- **Error Red**: #EF4444 (Error states)

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Consistent Spacing**: 8px base unit system
- **Proper Hierarchy**: Clear text size and weight hierarchy

## 📱 Screens

1. **Splash Screen**: Animated logo and app initialization
2. **Authentication**:
   - Login Screen
   - Sign Up Screen
   - Forgot Password Screen
3. **Main Application**:
   - Home Screen with room listings
   - Room Details Screen
   - Booking Screen
   - Booking History Screen
   - Profile Screen
4. **Admin Panel** (Admin Users Only):
   - Admin Rooms Screen: View and manage all rooms
   - Add/Edit Room Screen: Create or modify room details

## 🛠 Technology Stack

### Frontend
- **Flutter**: Latest version with Material Design 3
- **Dart**: Modern Dart features and null safety

### Backend Services
- **Firebase Authentication**: Secure user management
- **Cloud Firestore**: NoSQL database for rooms and bookings
- **Firebase Storage**: Image storage for room photos

### State Management
- **Provider**: Reactive state management
- **Change Notifier**: For complex state updates

### Payment
- **Razorpay**: Secure payment processing
- **Multiple Payment Methods**: Cards, UPI, Wallets

### Additional Packages
- **cached_network_image**: Efficient image loading
- **carousel_slider**: Image carousels
- **google_fonts**: Typography
- **lottie**: Animations
- **email_validator**: Form validation

## 🏗 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart       # User with role-based access (user/admin)
│   ├── room_model.dart
│   └── booking_model.dart
├── services/                 # Firebase services
│   ├── auth_service.dart     # Authentication with role assignment
│   ├── room_service.dart     # Room CRUD operations
│   └── booking_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── room_provider.dart    # Admin CRUD methods
│   └── booking_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   ├── home/
│   ├── room/
│   ├── booking/
│   └── admin/                # Admin panel
│       ├── admin_rooms_screen.dart
│       └── add_edit_room_screen.dart
├── widgets/                  # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── room_card.dart        # With availability badge
│   └── booking_card.dart
└── utils/                    # Utilities
    └── app_theme.dart
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (2.17+)
- Android Studio / VS Code
- Firebase Project

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd bookify-rooms
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in respective folders

4. **Razorpay Setup**
   - Create Razorpay account
   - Get API keys
   - Update the key in `booking_screen.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

### Creating an Admin User

By default, all new users are created with "user" role. To create an admin user:

1. **Sign up a new user** through the app
2. **Go to Firebase Console** → Firestore Database
3. **Find the user document** in the `users` collection
4. **Edit the document** and change the `role` field from `"user"` to `"admin"`
5. **Restart the app** and log in with that user
6. **Admin Panel button** will now appear in the Profile screen

Alternatively, you can manually create a user document with admin role:
```json
{
  "id": "user-uid",
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": 1234567890000,
  "updatedAt": 1234567890000
}
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 💳 Payment Integration

The app uses Razorpay for secure payment processing:
- Multiple payment methods supported
- Real-time payment status updates
- Secure payment flow
- Booking confirmation after successful payment

## 🔒 Security Features

- Firebase Security Rules
- Input validation
- Secure authentication
- Payment tokenization
- Data encryption

## 📊 Performance Optimizations

- Image caching with `cached_network_image`
- Lazy loading for room lists
- Efficient state management
- Optimized build methods
- Memory management

## 🎯 Future Enhancements

- [ ] Push notifications
- [ ] Advanced search filters
- [ ] User reviews and ratings
- [ ] Chat support
- [ ] Loyalty program
- [ ] Social login options
- [ ] Offline support
- [ ] Dark mode theme
- [ ] Admin booking management screen
- [ ] Dashboard statistics for admin
- [ ] Bulk room operations
- [ ] Export reports

## 📄 License

This project is created for portfolio purposes.

## 👨‍💻 Developer

Created as a portfolio project showcasing:
- Modern Flutter development
- Firebase integration
- Payment gateway implementation
- Clean architecture
- Beautiful UI/UX design
- Production-ready code quality

---

**Bookify Rooms** - Making room booking simple and beautiful! 🏨✨