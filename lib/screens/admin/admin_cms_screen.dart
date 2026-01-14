import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_v2.dart';
import '../../providers/room_provider_v2.dart';
import '../../providers/booking_provider_v2.dart';
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
        backgroundColor: Colors.blueAccent,
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
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.grey[100],
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.meeting_room),
                selectedIcon: Icon(Icons.meeting_room, color: Colors.blueAccent),
                label: Text('Rooms'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                selectedIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                label: Text('Bookings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people, color: Colors.blueAccent),
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
    );
  }
}
