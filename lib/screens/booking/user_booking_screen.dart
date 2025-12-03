import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class UserBookingScreen extends StatefulWidget {
  final RoomModel room;

  const UserBookingScreen({
    super.key,
    required this.room,
  });

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  int _durationMinutes = 60;
  int _guestCount = 1;
  late TextEditingController _customDurationController;
  late TextEditingController _purposeController;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _customDurationController = TextEditingController();
    _purposeController = TextEditingController();
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  TimeOfDay _calculateEndTime() {
    final minutes = int.tryParse(_customDurationController.text) ?? _durationMinutes;
    final totalMinutes = _startTime.hour * 60 + _startTime.minute + minutes;
    final hours = (totalMinutes ~/ 60) % 24;
    final mins = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
  }

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleBooking() async {
    if (!widget.room.isAvailable) {
      _showErrorSnackBar(
        title: 'Room Not Available',
        message: 'This room is currently not available for booking.',
      );
      return;
    }

    // Validate selected date is not in the past
    final today = DateTime.now();
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    if (selectedDateOnly.isBefore(todayOnly)) {
      _showErrorSnackBar(
        title: 'Invalid Date',
        message: 'Cannot book dates in the past. Please select today or a future date.',
      );
      return;
    }

    // Validate guest count
    if (_guestCount > widget.room.maxGuests) {
      _showErrorSnackBar(
        title: 'Exceeds Capacity',
        message: 'Number of guests (${_guestCount}) exceeds room capacity (${widget.room.maxGuests}).',
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();

      if (authProvider.user == null) {
        throw 'User not authenticated. Please login again.';
      }

      final endTime = _calculateEndTime();

      debugPrint('🔍 Attempting booking:');
      debugPrint('   Room ID: ${widget.room.id}');
      debugPrint('   Date: ${_selectedDate.toString().split(' ')[0]}');
      debugPrint('   Time: ${_timeToString(_startTime)} - ${_timeToString(endTime)}');
      debugPrint('   Guests: $_guestCount');

      final bookingId = await bookingProvider.createBooking(
        userId: authProvider.user!.uid,
        roomId: widget.room.id,
        bookingDate: _selectedDate,
        checkInTime: _timeToString(_startTime),
        checkOutTime: _timeToString(endTime),
        numberOfGuests: _guestCount,
        purpose: _purposeController.text.isNotEmpty ? _purposeController.text : null,
      );

      // Check if booking creation failed
      if (bookingId == null) {
        final errorMsg = bookingProvider.errorMessage ?? 'Unknown error occurred';
        throw errorMsg;
      }

      debugPrint('✅ Booking created successfully with ID: $bookingId');

      if (mounted) {
        _showSuccessSnackBar(
          title: 'Booking Confirmed!',
          message: '${widget.room.name}\n${_timeToString(_startTime)} - ${_timeToString(endTime)}\n$_guestCount guest${_guestCount > 1 ? 's' : ''}',
        );
        
        // Pop after brief delay to show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Booking error: $e');
      
      final errorString = e.toString();
      String title = 'Booking Failed';
      String message = 'An unexpected error occurred.';

      if (errorString.contains('not available for the selected')) {
        title = 'Time Slot Unavailable';
        message = 'This time slot is already booked.\nPlease select another time or date.';
      } else if (errorString.contains('exceeds room capacity')) {
        title = 'Capacity Exceeded';
        message = 'Too many guests for this room.\nPlease reduce guest count.';
      } else if (errorString.contains('Room not found')) {
        title = 'Room Not Found';
        message = 'This room no longer exists.\nPlease try another room.';
      } else if (errorString.contains('not authenticated')) {
        title = 'Authentication Error';
        message = 'You are not logged in. Please login and try again.';
      } else if (errorString.contains('permission-denied')) {
        title = 'Permission Denied';
        message = 'You do not have permission to create bookings.';
      } else {
        message = errorString.replaceAll('Exception: ', '').replaceAll('Error creating booking: ', '');
      }

      if (mounted) {
        _showErrorSnackBar(title: title, message: message);
      }
    } finally {
      setState(() => _isBooking = false);
    }
  }

  void _showSuccessSnackBar({
    required String title,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar({
    required String title,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _durationButton(int minutes, String label) {
    final isCustom = _customDurationController.text.isNotEmpty;
    final isSelected = (!isCustom && _durationMinutes == minutes) ||
        (isCustom && int.tryParse(_customDurationController.text) == minutes);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _durationMinutes = minutes;
            _customDurationController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.white,
            border: Border.all(
              color: AppColors.primaryRed,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _calculateEndTime();
    final displayDuration = _customDurationController.text.isNotEmpty
        ? int.tryParse(_customDurationController.text) ?? _durationMinutes
        : _durationMinutes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.room.name}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Room Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryRedLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 40,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.room.maxGuests} guests • ${widget.room.hasAC ? 'AC' : 'Fan'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Date Selection
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Start Time Selection
              Text(
                'Start Time',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (picked != null) {
                    setState(() => _startTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _timeToString(_startTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Duration Selection
              Text(
                'Duration',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _durationButton(30, '30 min'),
                  const SizedBox(width: 8),
                  _durationButton(60, '60 min'),
                  const SizedBox(width: 8),
                  _durationButton(90, '90 min'),
                ],
              ),
              const SizedBox(height: 12),

              // Custom Duration
              Text(
                'Custom Duration (minutes)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _customDurationController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Enter custom duration',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryRedLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryRedLight.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Slot:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_timeToString(_startTime)} - ${_timeToString(endTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '$displayDuration minutes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Guest Count
              Text(
                'Guests',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _guestCount > 1
                          ? () => setState(() => _guestCount--)
                          : null,
                    ),
                    Text(
                      _guestCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _guestCount < widget.room.maxGuests
                          ? () => setState(() => _guestCount++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Purpose (optional)
              Text(
                'Purpose (optional)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _purposeController,
                decoration: InputDecoration(
                  hintText: 'e.g., Meeting, Training, Class',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.room.isAvailable && !_isBooking
                      ? _handleBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    disabledBackgroundColor: AppColors.borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isBooking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Confirm Booking',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
