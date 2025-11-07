import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/booking_provider.dart';
import 'services/sample_data_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize sample room data (using free images)
  try {
    await SampleDataService.initializeSampleData();
  } catch (e) {
    print('Note: Sample data initialization will happen after authentication');
  }

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
