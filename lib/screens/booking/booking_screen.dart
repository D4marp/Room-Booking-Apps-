import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final RoomModel room;

  const BookingScreen({
    super.key,
    required this.room,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 0);
  int _guestCount = 1;
  bool _isBooking = false;
  final TextEditingController _purposeController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 2));
  }

  // Book room - simplified
  void _bookRoom() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-out date must be after check-in date'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    try {
      final userId = authProvider.user!.uid;
      final roomId = widget.room.id;
      
      // Format times as "HH:mm"
      final checkInTimeStr = '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}';
      final checkOutTimeStr = '${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}';

      final bookingId = await bookingProvider.createBooking(
        userId: userId,
        roomId: roomId,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        checkInTime: checkInTimeStr,
        checkOutTime: checkOutTimeStr,
        numberOfGuests: _guestCount,
        purpose: _purposeController.text.trim().isNotEmpty ? _purposeController.text.trim() : null,
      );

      if (mounted && bookingId != null) {
        setState(() {
          _isBooking = false;
        });
        _showBookingSuccessDialog(bookingId);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _showBookingSuccessDialog(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your room has been booked successfully.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookingId,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Go to My Bookings',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back to room details
                  Navigator.of(context).pop(); // Back to home
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room info
            _buildRoomInfoCard(),

            const SizedBox(height: AppSpacing.xl),

            // Check-in date & time
            _buildCheckInSection(),

            const SizedBox(height: AppSpacing.lg),

            // Check-out date & time
            _buildCheckOutSection(),

            const SizedBox(height: AppSpacing.lg),

            // Guests
            _buildGuestCountSection(),

            const SizedBox(height: AppSpacing.lg),

            // Purpose
            _buildPurposeSection(),

            const SizedBox(height: AppSpacing.xl),

            // Total summary
            _buildSummary(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildRoomInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.room.imageUrls.isNotEmpty
                  ? widget.room.imageUrls.first
                  : 'https://via.placeholder.com/80',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.hotel, size: 30),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.room.location}, ${widget.room.city}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.room.capacityInfo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Date
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _checkInDate = picked;
                  if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
                    _checkOutDate = _checkInDate!.add(const Duration(days: 1));
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _checkInDate != null
                        ? 'Date: ${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Time
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _checkInTime,
              );
              if (picked != null) {
                setState(() {
                  _checkInTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Time: ${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-out',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Date
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _checkOutDate ?? DateTime.now().add(const Duration(days: 2)),
                firstDate: (_checkInDate ?? DateTime.now()).add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _checkOutDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _checkOutDate != null
                        ? 'Date: ${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Time
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _checkOutTime,
              );
              if (picked != null) {
                setState(() {
                  _checkOutTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Time: ${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCountSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Guests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Max: ${widget.room.maxGuests}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _guestCount > 1
                    ? () => setState(() => _guestCount--)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _guestCount > 1
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                ),
              ),
              Text(
                '$_guestCount',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: _guestCount < widget.room.maxGuests
                    ? () => setState(() => _guestCount++)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _guestCount < widget.room.maxGuests
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final days = _checkOutDate?.difference(_checkInDate ?? DateTime.now()).inDays ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Duration',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              Text(
                '$days ${days != 1 ? 'days' : 'day'}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of Guests',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              Text(
                '$_guestCount ${_guestCount > 1 ? 'guests' : 'guest'}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purpose of Booking (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _purposeController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g., Team meeting, Training session, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: _isBooking ? 'Booking...' : 'Book Room',
          onPressed: _isBooking ? null : _bookRoom,
          backgroundColor: widget.room.isAvailable
              ? AppColors.primaryBlue
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}
