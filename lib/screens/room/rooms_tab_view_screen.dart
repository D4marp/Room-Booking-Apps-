import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../providers/room_provider.dart';
import '../../utils/app_theme.dart';
import '../room/room_details_screen.dart';

class RoomsTabViewScreen extends StatefulWidget {
  const RoomsTabViewScreen({super.key});

  @override
  State<RoomsTabViewScreen> createState() => _RoomsTabViewScreenState();
}

class _RoomsTabViewScreenState extends State<RoomsTabViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RoomModel> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  Future<void> _loadRooms() async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    await roomProvider.loadRooms();
    
    if (mounted) {
      setState(() {
        _rooms = roomProvider.allRooms;
        _isLoading = false;
        if (_rooms.isNotEmpty) {
          _tabController = TabController(length: _rooms.length, vsync: this);
        }
      });
    }
  }

  @override
  void dispose() {
    if (_rooms.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rooms Overview'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (_rooms.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rooms Overview'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Rooms Available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add rooms from admin panel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightText,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.secondaryText,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              tabs: _rooms.map((room) {
                return Tab(
                  child: Row(
                    children: [
                      Icon(
                        _getRoomIcon(room.roomClass),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _rooms.map((room) {
          return _buildRoomDetailTab(room);
        }).toList(),
      ),
    );
  }

  Widget _buildRoomDetailTab(RoomModel room) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBlue.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Section - Compact
          Expanded(
            child: _buildCompactHeader(room),
          ),

          // Schedule Section - Fixed height
          Expanded(
            child: _buildScheduleList(room),
          ),

          // Bottom Action Buttons
          _buildActionButtons(room),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(RoomModel room) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Room Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoomIcon(room.roomClass),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.roomClass,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Time Range
          Row(
            children: [
              Expanded(
                child: _buildTimeBox('09:00', 'Start', 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.edit,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildTimeBox('17:00', 'End', 20),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Location & Status Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        room.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: room.isAvailable ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (room.isAvailable ? Colors.green : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  room.isAvailable ? 'Available' : 'Booked',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String time, String label, double fontSize) {
    return Column(
      children: [
        Text(
          time,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(RoomModel room) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Schedule Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                ),
              ],
            ),
          ),

          // Schedule Items - Limited height
          Expanded(
            child: ListView.separated(
              itemCount: 4, // Fixed 4 items max
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 0,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final times = ['09:00-10:15', '10:30-11:45', '12:30-14:00', '14:30-16:00'];
                final events = ['Weekly meeting', 'Engineering meeting', 'ISO meeting', 'Design studio'];
                final isActive = index == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  color: isActive
                      ? AppColors.primaryBlue.withOpacity(0.05)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      // Time Line Indicator
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      // Event Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              times[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.secondaryText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              events[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RoomModel room) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: room.isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailsScreen(room: room),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: room.isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailsScreen(room: room),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Book'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                disabledForegroundColor: Colors.grey.shade400,
                side: BorderSide(
                  color: room.isAvailable
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoomIcon(String roomClass) {
    switch (roomClass.toLowerCase()) {
      case 'meeting room':
        return Icons.groups;
      case 'conference room':
        return Icons.business;
      case 'class room':
        return Icons.school;
      case 'lecture hall':
        return Icons.theater_comedy;
      case 'training room':
        return Icons.model_training;
      case 'board room':
        return Icons.dashboard;
      case 'study room':
        return Icons.menu_book;
      case 'lab':
        return Icons.science;
      default:
        return Icons.meeting_room;
    }
  }
}
