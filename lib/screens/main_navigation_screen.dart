import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_v2.dart';
import '../screens/admin/admin_cms_screen.dart';
import '../screens/room/room_list_screen.dart';
import '../screens/home/home_screen.dart';

/// Main navigation screen with 3 views: User, Room, and Admin (CMS)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const HomeScreen(), // User View
    const RoomListScreen(), // Room View
    if (context.read<AuthProvider>().isAdmin)
      const AdminCMSScreen(), // Admin CMS View
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Redirect to login if not authenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(), // User View - Index 0
          const RoomListScreen(), // Room View - Index 1
          if (authProvider.isAdmin) const AdminCMSScreen(), // Admin CMS View - Index 2
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Prevent access to admin if not admin
          if (index == 2 && !authProvider.isAdmin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access denied')),
            );
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          if (authProvider.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin CMS',
            ),
        ],
      ),
    );
  }
}
