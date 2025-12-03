import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../providers/room_provider.dart';
import '../../providers/booking_provider.dart';
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
  Map<String, List<BookingModel>> _roomBookings = {};
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
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    await roomProvider.loadRooms();
    
    if (mounted) {
      setState(() {
        _rooms = roomProvider.allRooms;
        
        if (_rooms.isNotEmpty) {
          _tabController = TabController(length: _rooms.length, vsync: this);
          // Load bookings for each room
          _loadBookingsForRooms(bookingProvider);
        }
        
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookingsForRooms(BookingProvider bookingProvider) async {
    for (var room in _rooms) {
      try {
        final bookings = await bookingProvider.getBookingsByRoomId(room.id);
        if (mounted) {
          setState(() {
            _roomBookings[room.id] = bookings;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _roomBookings[room.id] = [];
          });
        }
        debugPrint('Error loading bookings for room ${room.id}: $e');
      }
    }
  }

  List<BookingModel> _getTodayBookings(String roomId) {
    final bookings = _roomBookings[roomId] ?? [];
    final today = DateTime.now();
    
    try {
      return bookings.where((booking) {
        return booking.bookingDate.year == today.year &&
            booking.bookingDate.month == today.month &&
            booking.bookingDate.day == today.day;
      }).toList()..sort((a, b) {
        try {
          final aHour = int.parse(a.checkInTime.split(':')[0]);
          final aMin = int.parse(a.checkInTime.split(':')[1]);
          final bHour = int.parse(b.checkInTime.split(':')[0]);
          final bMin = int.parse(b.checkInTime.split(':')[1]);
          
          final aTotal = aHour * 60 + aMin;
          final bTotal = bHour * 60 + bMin;
          return aTotal.compareTo(bTotal);
        } catch (e) {
          debugPrint('Error comparing booking times: $e');
          return 0;
        }
      });
    } catch (e) {
      debugPrint('Error filtering today bookings: $e');
      return [];
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
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
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: AppColors.secondaryText,
              indicatorColor: AppColors.primaryRed,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Card - Modern Design
          Expanded(
            flex: 2,
            child: _buildModernHeader(room),
          ),

          // Bookings Schedule Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildBookingsSchedule(room),
            ),
          ),

          // Action Buttons
          _buildActionButtons(room),
        ],
      ),
    );
  }

  Widget _buildModernHeader(RoomModel room) {
    final statusColor = room.isAvailable
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB71C1C);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getRoomIcon(room.roomClass),
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.roomClass,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  room.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  room.isAvailable ? 'Available' : 'Booked',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),

          // Location & Capacity Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.secondaryText,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${room.location}, ${room.city}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryText,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${room.maxGuests}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSchedule(RoomModel room) {
    final todayBookings = _getTodayBookings(room.id);
    final statusColor = room.isAvailable
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB71C1C);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Schedule Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Schedule',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        todayBookings.isEmpty ? 'No bookings' : '${todayBookings.length} booking(s)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Schedule Items List
          Expanded(
            child: todayBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          color: Colors.grey.shade300,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No bookings today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: todayBookings.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade100,
                      height: 16,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      final booking = todayBookings[index];
                      final isActive = index == 0;

                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isActive
                              ? statusColor.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? statusColor.withOpacity(0.3)
                                : Colors.grey.shade100,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Range & Status Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${booking.checkInTime} - ${booking.checkOutTime}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? statusColor.withOpacity(0.15)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isActive ? 'Active' : booking.statusDisplayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isActive
                                                ? statusColor
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Guests & User Info
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 16,
                                    color: AppColors.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${booking.numberOfGuests} guest${booking.numberOfGuests > 1 ? 's' : ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.secondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  if (booking.userName != null && booking.userName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              booking.userName!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: statusColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (booking.purpose != null && booking.purpose!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.note_outlined,
                                            size: 16,
                                            color: AppColors.secondaryText,
                                          ),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              booking.purpose!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.secondaryText,
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
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
    final statusColor = room.isAvailable
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB71C1C);

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomDetailsScreen(room: room),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
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
              label: const Text('Book Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: statusColor,
                side: BorderSide(
                  color: room.isAvailable ? statusColor : Colors.grey.shade300,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
