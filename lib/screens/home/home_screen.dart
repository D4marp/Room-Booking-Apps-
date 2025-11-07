import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../services/sample_data_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/room_card.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../room/room_details_screen.dart';
import '../profile/profile_screen.dart';
import '../booking/booking_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      roomProvider.loadRooms();

      // Initialize sample data if needed (for demo purposes)
      _initializeSampleDataIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Initialize sample data for demo purposes
  Future<void> _initializeSampleDataIfNeeded() async {
    try {
      await SampleDataService.initializeSampleData();
    } catch (e) {
      print('Sample data initialization: $e');
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const BookingHistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightBlue,
            AppColors.creamBackground,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            Expanded(
              child: _buildRoomsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello ${authProvider.userModel?.name ?? 'User'}! 👋',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Find your perfect stay',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: authProvider.userModel?.profileImage != null
                      ? CachedNetworkImage(
                          imageUrl: authProvider.userModel!.profileImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(
                            Icons.person,
                            color: AppColors.primaryBlue,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Search rooms, locations...',
              onChanged: (query) {
                final roomProvider =
                    Provider.of<RoomProvider>(context, listen: false);
                roomProvider.searchRooms(query);
              },
              onClear: () {
                final roomProvider =
                    Provider.of<RoomProvider>(context, listen: false);
                roomProvider.searchRooms('');
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            decoration: AppDecorations.softShadowDecoration,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FilterBottomSheet(),
                );
              },
              icon: const Icon(
                Icons.tune,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        if (roomProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          );
        }

        if (roomProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorRed.withOpacity(0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.errorRed,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  roomProvider.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    roomProvider.clearError();
                    roomProvider.loadRooms();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (roomProvider.rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.lightText,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  roomProvider.hasActiveFilters
                      ? 'No rooms found with current filters'
                      : 'No rooms available',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  roomProvider.hasActiveFilters
                      ? 'Try adjusting your filters'
                      : 'Check back later for new listings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightText,
                      ),
                ),
                if (roomProvider.hasActiveFilters) ...[
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: roomProvider.clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          );
        }

        return Column(
          children: [
            // Results header
            if (roomProvider.hasActiveFilters ||
                roomProvider.searchQuery.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${roomProvider.filteredRoomCount} rooms found',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    if (roomProvider.hasActiveFilters)
                      GestureDetector(
                        onTap: roomProvider.clearFilters,
                        child: Text(
                          'Clear all',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),

            // Rooms list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await roomProvider.refresh();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: roomProvider.rooms.length,
                  itemBuilder: (context, index) {
                    final room = roomProvider.rooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RoomCard(
                        room: room,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomDetailsScreen(room: room),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.lightText,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
