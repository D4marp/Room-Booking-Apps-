# Bookify Rooms - Flutter Room Booking App

A comprehensive Flutter application for room booking with Firebase backend, featuring modern UI design, payment integration, and real-time booking management.

## 🚀 Features

### Core Functionality
- **User Authentication**: Email/Password and Google Sign-In
- **Room Browsing**: Beautiful room listings with search and filter
- **Booking System**: Date selection, guest count, price calculation
- **Payment Integration**: Razorpay payment gateway
- **Booking Management**: View and manage bookings history
- **User Profile**: Profile management and settings

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
│   ├── user_model.dart
│   ├── room_model.dart
│   └── booking_model.dart
├── services/                 # Firebase services
│   ├── auth_service.dart
│   ├── room_service.dart
│   └── booking_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── room_provider.dart
│   └── booking_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   ├── home/
│   ├── room/
│   └── booking/
├── widgets/                  # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── room_card.dart
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