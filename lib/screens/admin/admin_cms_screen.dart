import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_v2.dart';
import '../../providers/room_provider_v2.dart';
import '../../providers/booking_provider_v2.dart';
import '../../utils/app_theme.dart';
import '../../core/gen/assets.gen.dart';
import 'admin_rooms_cms_screen.dart';
import 'admin_bookings_cms_screen.dart';
import 'admin_users_cms_screen.dart';

class AdminCMSScreen extends StatefulWidget {
  const AdminCMSScreen({super.key});

  @override
  State<AdminCMSScreen> createState() => _AdminCMSScreenState();
}

class _AdminCMSScreenState extends State<AdminCMSScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminRoomsCMSScreen(),
    const AdminBookingsCMSScreen(),
    const AdminUsersCMSScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.delayed(Duration.zero, () {
      context.read<RoomProvider>().fetchRooms();
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    // Check if user is admin
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin CMS - Room Booking System'),
        elevation: 0,
        backgroundColor: AppColors.primaryRed,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                authProvider.userModel?.name ?? 'Admin',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  await authProvider.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/auth',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.creamBackground,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.tabScreen.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            // Sidebar
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: AppColors.primaryRed),
              unselectedIconTheme: const IconThemeData(color: AppColors.secondaryText),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.meeting_room),
                  label: Text('Rooms'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Users'),
                ),
              ],
            ),
            // Content
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
