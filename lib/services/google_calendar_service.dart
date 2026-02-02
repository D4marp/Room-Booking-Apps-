// lib/services/google_calendar_service.dart

import 'package:flutter/foundation.dart';
import 'api_service.dart';

class GoogleCalendarService extends ChangeNotifier {
  String? _userEmail;
  bool _isConnected = false;

  GoogleCalendarService() {
    // Initialize service
  }

  // Getters
  bool get isConnected => _isConnected;
  String? get userEmail => _userEmail;

  /// ========================================
  /// Authentication Methods
  /// ========================================

  /// Login dengan Google
  Future<bool> signInWithGoogle({
    required String accessToken,
    String? idToken,
    required String email,
  }) async {
    try {
      _userEmail = email;

      // Kirim ke backend
      final response = await ApiService().post(
        '/calendar/auth/google',
        data: {
          'access_token': accessToken,
          'id_token': idToken,
          'email': email,
        },
      );

      if (response['user_id'] != null) {
        _isConnected = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return false;
    }
  }

  /// Logout dari Google
  Future<void> signOutGoogle() async {
    try {
      // Disconnect dari backend
      await ApiService().post('/calendar/disconnect', data: {});

      _userEmail = null;
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  /// Disconnect dari Google Calendar
  Future<void> disconnect() async {
    await signOutGoogle();
  }

  /// ========================================
  /// Calendar Event Methods
  /// ========================================

  /// Sinkronisasi booking ke Google Calendar
  Future<Map<String, dynamic>?> syncBookingToCalendar({
    required String bookingId,
    required String roomId,
    required String roomName,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> attendees,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Google Calendar not connected');
      }

      final response = await ApiService().post(
        '/calendar/sync',
        data: {
          'booking_id': bookingId,
          'room_id': roomId,
          'room_name': roomName,
          'title': title,
          'description': description,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'attendees': attendees,
        },
      );

      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('Sync Booking Error: $e');
      rethrow;
    }
  }

  /// Ambil semua events dari Google Calendar
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    int? month,
    int? year,
    String? roomId,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Google Calendar not connected');
      }

      final queryParams = <String, String>{};
      if (month != null) queryParams['month'] = month.toString();
      if (year != null) queryParams['year'] = year.toString();
      if (roomId != null) queryParams['room_id'] = roomId;

      // Build query string
      String endpoint = '/calendar/events';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await ApiService().get(endpoint);

      final events = List<Map<String, dynamic>>.from(
        (response['data'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
      );

      return events;
    } catch (e) {
      debugPrint('Get Calendar Events Error: $e');
      return [];
    }
  }

  /// Ambil events untuk ruangan tertentu
  Future<List<Map<String, dynamic>>> getRoomEvents({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Google Calendar not connected');
      }

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final response = await ApiService().get(
        '/calendar/rooms/$roomId/events?start_date=$startDateStr&end_date=$endDateStr',
      );

      final events = List<Map<String, dynamic>>.from(
        (response['events'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
      );

      return events;
    } catch (e) {
      debugPrint('Get Room Events Error: $e');
      return [];
    }
  }

  /// Hapus event dari Google Calendar
  Future<bool> deleteCalendarEvent(String eventId) async {
    try {
      if (!_isConnected) {
        throw Exception('Google Calendar not connected');
      }

      await ApiService().delete('/calendar/events/$eventId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete Event Error: $e');
      return false;
    }
  }

  /// ========================================
  /// Availability Methods
  /// ========================================

  /// Cek ketersediaan ruangan
  Future<List<Map<String, dynamic>>?> checkRoomAvailability({
    required String roomId,
    required DateTime date,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Google Calendar not connected');
      }

      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await ApiService().get(
        '/calendar/rooms/$roomId/availability?date=$dateStr',
      );

      final slots = List<Map<String, dynamic>>.from(
        (response['slots'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
      );

      return slots;
    } catch (e) {
      debugPrint('Check Availability Error: $e');
      return null;
    }
  }

  /// ========================================
  /// Notification Methods
  /// ========================================

  /// Kirim notifikasi booking
  Future<bool> sendBookingNotification({
    required String userId,
    required String bookingId,
    required String roomName,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String userEmail,
  }) async {
    try {
      await ApiService().post(
        '/calendar/notifications',
        data: {
          'user_id': userId,
          'booking_id': bookingId,
          'room_name': roomName,
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'user_email': userEmail,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Send Notification Error: $e');
      return false;
    }
  }

  /// ========================================
  /// Reminder Methods
  /// ========================================

  /// Schedule reminder untuk booking
  Future<bool> scheduleReminder({
    required String bookingId,
    required String userId,
    required String roomName,
    required DateTime startTime,
    required int reminderMinutes,
  }) async {
    try {
      await ApiService().post(
        '/calendar/reminders',
        data: {
          'booking_id': bookingId,
          'user_id': userId,
          'room_name': roomName,
          'start_time': startTime.toIso8601String(),
          'reminder_minutes': reminderMinutes,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Schedule Reminder Error: $e');
      return false;
    }
  }

  /// ========================================
  /// Helper Methods
  /// ========================================

  /// Format time untuk display
  String formatEventTime(DateTime start, DateTime end) {
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  /// Check if event is today
  bool isEventToday(DateTime eventDate) {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  /// Check if event is upcoming (within 24 hours)
  bool isEventUpcoming(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);
    return difference.isNegative == false && difference.inHours <= 24;
  }
}
