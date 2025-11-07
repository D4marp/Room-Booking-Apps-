import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bookings';
  static const Uuid _uuid = Uuid();

  // Create a new booking
  static Future<String> createBooking({
    required String userId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required double totalAmount,
  }) async {
    try {
      // Check room availability first
      bool isAvailable =
          await RoomService.isRoomAvailable(roomId, checkInDate, checkOutDate);
      if (!isAvailable) {
        throw 'Room is not available for the selected dates.';
      }

      // Get room details for the booking
      RoomModel? room = await RoomService.getRoomById(roomId);
      if (room == null) {
        throw 'Room not found.';
      }

      final bookingId = _uuid.v4();
      final booking = BookingModel(
        id: bookingId,
        userId: userId,
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        totalAmount: totalAmount,
        status: BookingStatus.pending,
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now(),
        roomName: room.name,
        roomLocation: room.location,
        roomImageUrl: room.primaryImageUrl,
      );

      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .set(booking.toJson());
      return bookingId;
    } catch (e) {
      throw 'Error creating booking: $e';
    }
  }

  // Update booking payment status
  static Future<void> updateBookingPayment({
    required String bookingId,
    required PaymentStatus paymentStatus,
    String? paymentId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'paymentStatus': paymentStatus.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (paymentId != null) updateData['paymentId'] = paymentId;
      if (razorpayOrderId != null)
        updateData['razorpayOrderId'] = razorpayOrderId;
      if (razorpayPaymentId != null)
        updateData['razorpayPaymentId'] = razorpayPaymentId;
      if (razorpaySignature != null)
        updateData['razorpaySignature'] = razorpaySignature;

      // If payment is successful, confirm the booking
      if (paymentStatus == PaymentStatus.paid) {
        updateData['status'] = BookingStatus.confirmed.name;
      }

      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update(updateData);
    } catch (e) {
      throw 'Error updating booking payment: $e';
    }
  }

  // Cancel booking
  static Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Error cancelling booking: $e';
    }
  }

  // Get user bookings
  static Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get booking by ID
  static Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw 'Error fetching booking: $e';
    }
  }

  // Get all bookings (Admin function)
  static Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get bookings by status
  static Stream<List<BookingModel>> getBookingsByStatus(BookingStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get room bookings for specific dates (Admin function)
  static Future<List<BookingModel>> getRoomBookingsForPeriod({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('roomId', isEqualTo: roomId)
          .where('checkInDate',
              isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .where('checkOutDate',
              isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Error fetching room bookings: $e';
    }
  }

  // Calculate total price for booking
  static double calculateTotalPrice({
    required double pricePerNight,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) {
    final numberOfNights = checkOutDate.difference(checkInDate).inDays;
    if (numberOfNights <= 0) {
      throw 'Check-out date must be after check-in date';
    }
    return pricePerNight * numberOfNights;
  }

  // Get booking statistics (Admin function)
  static Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      QuerySnapshot allBookings =
          await _firestore.collection(_collection).get();

      QuerySnapshot confirmedBookings = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: BookingStatus.confirmed.name)
          .get();

      QuerySnapshot pendingBookings = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: BookingStatus.pending.name)
          .get();

      QuerySnapshot cancelledBookings = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: BookingStatus.cancelled.name)
          .get();

      // Calculate total revenue from paid bookings
      double totalRevenue = 0;
      for (var doc in allBookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['paymentStatus'] == PaymentStatus.paid.name) {
          totalRevenue += (data['totalAmount'] ?? 0.0).toDouble();
        }
      }

      return {
        'totalBookings': allBookings.size,
        'confirmedBookings': confirmedBookings.size,
        'pendingBookings': pendingBookings.size,
        'cancelledBookings': cancelledBookings.size,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw 'Error fetching booking statistics: $e';
    }
  }

  // Mark booking as completed (Admin function)
  static Future<void> markBookingCompleted(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.completed.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Error marking booking as completed: $e';
    }
  }

  // Get upcoming bookings for a user
  static Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    try {
      final now = DateTime.now();
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('checkInDate', isGreaterThan: now.millisecondsSinceEpoch)
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('checkInDate')
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Error fetching upcoming bookings: $e';
    }
  }

  // Get past bookings for a user
  static Future<List<BookingModel>> getPastBookings(String userId) async {
    try {
      final now = DateTime.now();
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('checkOutDate', isLessThan: now.millisecondsSinceEpoch)
          .orderBy('checkOutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Error fetching past bookings: $e';
    }
  }
}
