import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider_v2.dart';
import '../../utils/app_theme.dart';
import '../../core/gen/assets.gen.dart';

class AdminBookingsCMSScreen extends StatefulWidget {
  const AdminBookingsCMSScreen({super.key});

  @override
  State<AdminBookingsCMSScreen> createState() => _AdminBookingsCMSScreenState();
}

class _AdminBookingsCMSScreenState extends State<AdminBookingsCMSScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          appBar: AppBar(
            title: const Text('Booking Management'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.primaryText,
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.tabScreen.path),
                fit: BoxFit.cover,
              ),
            ),
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookingProvider.bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No bookings available',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Booking ID')),
                                    DataColumn(label: Text('Room')),
                                    DataColumn(label: Text('User')),
                                    DataColumn(label: Text('Start Time')),
                                    DataColumn(label: Text('End Time')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: [],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
