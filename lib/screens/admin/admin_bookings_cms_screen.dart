import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider_v2.dart';

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
          appBar: AppBar(
            title: const Text('Booking Management'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: bookingProvider.isLoading
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
                          rows: bookingProvider.bookings.map((booking) {
                            return DataRow(cells: [
                              DataCell(Text(booking.id)),
                              DataCell(Text(booking.roomId)),
                              DataCell(Text(booking.userId)),
                              DataCell(Text(booking.startTime.toString().split('.')[0])),
                              DataCell(Text(booking.endTime.toString().split('.')[0])),
                              DataCell(
                                Chip(
                                  label: Text(booking.status),
                                  backgroundColor: _getStatusColor(booking.status),
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              ),
                              DataCell(
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    if (booking.status == 'pending')
                                      PopupMenuItem(
                                        child: const Text('Approve'),
                                        onTap: () async {
                                          final updated = booking.copyWith(status: 'approved');
                                          await context
                                              .read<BookingProvider>()
                                              .updateBooking(booking.id, updated);
                                        },
                                      ),
                                    if (booking.status != 'cancelled')
                                      PopupMenuItem(
                                        child: const Text('Cancel'),
                                        onTap: () async {
                                          await context
                                              .read<BookingProvider>()
                                              .cancelBooking(booking.id);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
