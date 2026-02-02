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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    bool isLargeScreen = MediaQuery.of(context).size.width > 1000;

    // Redirect to login if not authenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isLargeScreen) {
      // Desktop layout with sidebar
      return Scaffold(
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
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Colors.blue),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.meeting_room),
                  label: Text('Rooms'),
                ),
                if (authProvider.isAdmin)
                  const NavigationRailDestination(
                    icon: Icon(Icons.admin_panel_settings),
                    label: Text('Admin'),
                  ),
              ],
            ),
            // Main content
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const HomeScreen(),
                  const RoomListScreen(),
                  if (authProvider.isAdmin) const AdminCMSScreen(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomeScreen(),
            const RoomListScreen(),
            if (authProvider.isAdmin) const AdminCMSScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
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
                label: 'Admin',
              ),
          ],
        ),
      );
    }
  }
}
