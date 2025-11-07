import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';  // Temporarily removed
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
  DateTime? _selectedDate;
  int _guestCount = 1;
  // late Razorpay _razorpay;  // Temporarily commented for APK build
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // Mock payment implementation - no Razorpay initialization needed
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    // _razorpay.clear();  // Commented out for mock implementation
  }

  // Mock payment success handler
  void _handleMockPaymentSuccess() async {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    // Create booking through the provider
    final userId = authProvider.user!.uid;
    final roomId = widget.room.id;
    final checkInDate = _selectedDate!;
    final checkOutDate = _selectedDate!.add(const Duration(days: 1));
    final numberOfGuests = _guestCount;
    final totalAmount = _calculateTotalAmount();

    try {
      final bookingId = await bookingProvider.createBooking(
        userId: userId,
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        totalAmount: totalAmount,
      );

      if (mounted && bookingId != null) {
        setState(() {
          _isProcessingPayment = false;
        });

        // Show success dialog with mock payment ID
        _showBookingConfirmationDialog(
            bookingId, 'mock_payment_${DateTime.now().millisecondsSinceEpoch}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
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

  double _calculateTotalAmount() {
    // Base price per night
    double basePrice = widget.room.pricePerNight;

    // Additional guest charges (if more than 2 guests)
    double guestCharges = _guestCount > 2 ? (_guestCount - 2) * 500 : 0;

    // Service charge (10%)
    double serviceCharge = (basePrice + guestCharges) * 0.1;

    // Tax (18% GST)
    double tax = (basePrice + guestCharges + serviceCharge) * 0.18;

    return basePrice + guestCharges + serviceCharge + tax;
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _processPayment() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a check-in date'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    // Mock payment processing - simulate payment success after 2 seconds
    try {
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, always succeed
      // In a real app with Razorpay, there would be actual payment processing here
      _handleMockPaymentSuccess();
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment initialization failed: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showBookingConfirmationDialog(String bookingId, String paymentId) {
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
                'Your booking has been confirmed. You will receive a confirmation email shortly.',
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
                      'Booking ID: $bookingId',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment ID: $paymentId',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'Go to My Bookings',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to room details
                Navigator.of(context).pop(); // Go back to home
                // Navigate to bookings tab (you might need to handle this differently)
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount();

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
            // Room info card
            _buildRoomInfoCard(),

            const SizedBox(height: AppSpacing.lg),

            // Date selection
            _buildDateSelection(),

            const SizedBox(height: AppSpacing.lg),

            // Guest count
            _buildGuestCountSection(),

            const SizedBox(height: AppSpacing.lg),

            // Price breakdown
            _buildPriceBreakdown(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(totalAmount),
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
                  child: const Icon(
                    Icons.hotel,
                    size: 30,
                    color: AppColors.lightText,
                  ),
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
                        color: AppColors.primaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.room.location}, ${widget.room.city}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.room.formattedPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildDateSelection() {
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
            'Check-in Date',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: _showDatePicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select check-in date',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedDate != null
                              ? AppColors.primaryText
                              : AppColors.secondaryText,
                        ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check-out: ${_selectedDate != null ? "${_selectedDate!.add(const Duration(days: 1)).day}/${_selectedDate!.add(const Duration(days: 1)).month}/${_selectedDate!.add(const Duration(days: 1)).year}" : "Select date first"}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Guests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton(
                onPressed: _guestCount > 1
                    ? () {
                        setState(() {
                          _guestCount--;
                        });
                      }
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _guestCount > 1
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$_guestCount',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                ),
              ),
              IconButton(
                onPressed: _guestCount < widget.room.maxGuests
                    ? () {
                        setState(() {
                          _guestCount++;
                        });
                      }
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _guestCount < widget.room.maxGuests
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                ),
              ),
              const Spacer(),
              Text(
                'Max: ${widget.room.maxGuests}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
            ],
          ),
          if (_guestCount > 2)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Additional guest charges apply for more than 2 guests',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final basePrice = widget.room.pricePerNight;
    final guestCharges = _guestCount > 2 ? (_guestCount - 2) * 500 : 0;
    final serviceCharge = (basePrice + guestCharges) * 0.1;
    final tax = (basePrice + guestCharges + serviceCharge) * 0.18;
    final total = basePrice + guestCharges + serviceCharge + tax;

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
            'Price Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPriceRow('Room (1 night)', '₹${basePrice.toStringAsFixed(0)}'),
          if (guestCharges > 0)
            _buildPriceRow(
              'Additional guests (${_guestCount - 2})',
              '₹${guestCharges.toStringAsFixed(0)}',
            ),
          _buildPriceRow(
              'Service charge', '₹${serviceCharge.toStringAsFixed(0)}'),
          _buildPriceRow('Tax (GST)', '₹${tax.toStringAsFixed(0)}'),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(double totalAmount) {
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
          text: _isProcessingPayment
              ? 'Processing...'
              : 'Pay ₹${totalAmount.toStringAsFixed(0)}',
          onPressed: _isProcessingPayment || !widget.room.isAvailable
              ? null
              : _processPayment,
          backgroundColor: widget.room.isAvailable
              ? AppColors.primaryBlue
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}
