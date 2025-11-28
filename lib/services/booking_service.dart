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
    required String checkInTime,
    required String checkOutTime,
    required int numberOfGuests,
    String? purpose,
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

      // Check capacity
      if (numberOfGuests > room.maxGuests) {
        throw 'Number of guests exceeds room capacity (${room.maxGuests} people).';
      }

      final bookingId = _uuid.v4();
      final booking = BookingModel(
        id: bookingId,
        userId: userId,
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        numberOfGuests: numberOfGuests,
        status: BookingStatus.confirmed, // Directly confirmed without payment
        createdAt: DateTime.now(),
        purpose: purpose,
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

  // Check time slot availability for a room on specific date
  static Future<bool> isTimeSlotAvailable({
    required String roomId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('roomId', isEqualTo: roomId)
          .where('checkInDate',
              isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .where('checkOutDate',
              isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (excludeBookingId != null && doc.id == excludeBookingId) continue;
        
        // Check time overlap
        final bookedStart = data['checkInTime'] as String;
        final bookedEnd = data['checkOutTime'] as String;
        
        if (_isTimeOverlap(startTime, endTime, bookedStart, bookedEnd)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      throw 'Error checking time slot availability: $e';
    }
  }

  // Helper method to check time overlap
  static bool _isTimeOverlap(String start1, String end1, String start2, String end2) {
    final start1Min = _timeToMinutes(start1);
    final end1Min = _timeToMinutes(end1);
    final start2Min = _timeToMinutes(start2);
    final end2Min = _timeToMinutes(end2);
    
    return !(end1Min <= start2Min || start1Min >= end2Min);
  }

  // Convert time string (HH:mm) to minutes since midnight
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
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

      QuerySnapshot completedBookings = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: BookingStatus.completed.name)
          .get();

      return {
        'totalBookings': allBookings.size,
        'confirmedBookings': confirmedBookings.size,
        'pendingBookings': pendingBookings.size,
        'cancelledBookings': cancelledBookings.size,
        'completedBookings': completedBookings.size,
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

  // Get all bookings for a specific room
  static Future<List<BookingModel>> getBookingsByRoomId(String roomId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('roomId', isEqualTo: roomId)
          .orderBy('checkInDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Error fetching bookings for room: $e';
    }
  }
}
