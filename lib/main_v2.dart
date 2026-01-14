import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider_v2.dart';
import 'providers/room_provider_v2.dart';
import 'providers/booking_provider_v2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Firebase initialization removed - now using Golang backend API
  // API base URL: http://localhost:8080 or configured in ApiConfig
  
  runApp(const BookifyRoomsApp());
}

class BookifyRoomsApp extends StatelessWidget {
  const BookifyRoomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Bookify Rooms',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
