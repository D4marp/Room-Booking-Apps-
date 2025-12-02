import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/booking_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load bookings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);

      if (authProvider.user != null) {
        bookingProvider.loadUserBookings(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryRed,
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
              ),
            );
          }

          if (bookingProvider.errorMessage != null) {
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
                    bookingProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(bookingProvider.userBookings, 'all'),
              _buildBookingsList(bookingProvider.upcomingBookings, 'upcoming'),
              _buildBookingsList(bookingProvider.pastBookings, 'past'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(type),
              size: 64,
              color: AppColors.lightText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _getEmptyStateTitle(type),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getEmptyStateSubtitle(type),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bookingProvider =
            Provider.of<BookingProvider>(context, listen: false);

        if (authProvider.user != null) {
          await bookingProvider.refreshBookings(authProvider.user!.uid);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BookingCard(
              booking: booking,
              onTap: () {
                // Navigate to booking details
                _showBookingDetails(booking);
              },
              onCancel:
                  booking.canBeCancelled ? () => _cancelBooking(booking) : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getEmptyStateIcon(String type) {
    switch (type) {
      case 'upcoming':
        return Icons.upcoming;
      case 'past':
        return Icons.history;
      default:
        return Icons.book_outlined;
    }
  }

  String _getEmptyStateTitle(String type) {
    switch (type) {
      case 'upcoming':
        return 'No Upcoming Bookings';
      case 'past':
        return 'No Past Bookings';
      default:
        return 'No Bookings Yet';
    }
  }

  String _getEmptyStateSubtitle(String type) {
    switch (type) {
      case 'upcoming':
        return 'You don\'t have any upcoming reservations.\nStart planning your next getaway!';
      case 'past':
        return 'You haven\'t completed any stays yet.\nYour booking history will appear here.';
      default:
        return 'You haven\'t made any reservations yet.\nExplore amazing rooms and book your perfect stay!';
    }
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(booking: booking),
    );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final bookingProvider =
                  Provider.of<BookingProvider>(context, listen: false);
              final success = await bookingProvider.cancelBooking(booking.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(bookingProvider.errorMessage ??
                        'Failed to cancel booking'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Booking Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    // Booking ID and Status
                    _buildDetailRow('Booking ID', booking.id),
                    _buildDetailRow('Status', booking.statusDisplayName),

                    const Divider(height: AppSpacing.xl),

                    // Room Details
                    if (booking.roomName != null) ...[
                      _buildDetailRow('Room', booking.roomName!),
                      if (booking.roomLocation != null)
                        _buildDetailRow('Location', booking.roomLocation!),
                    ],

                    const Divider(height: AppSpacing.xl),

                    // Booking Details
                    _buildDetailRow(
                        'Date', _formatDate(booking.bookingDate)),
                    _buildDetailRow(
                        'Time', '${booking.checkInTime} - ${booking.checkOutTime}'),
                    _buildDetailRow('Guests', '${booking.numberOfGuests}'),
                    if (booking.purpose != null && booking.purpose!.isNotEmpty)
                      _buildDetailRow('Purpose', booking.purpose!),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
