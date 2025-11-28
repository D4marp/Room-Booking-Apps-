import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _userBookings = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Current booking being created
  BookingModel? _currentBooking;
  DateTime? _selectedCheckInDate;
  DateTime? _selectedCheckOutDate;
  int _numberOfGuests = 1;

  // Getters
  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get pastBookings => _pastBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingModel? get currentBooking => _currentBooking;
  DateTime? get selectedCheckInDate => _selectedCheckInDate;
  DateTime? get selectedCheckOutDate => _selectedCheckOutDate;
  int get numberOfGuests => _numberOfGuests;

  // Load user bookings
  void loadUserBookings(String userId) {
    try {
      _clearError();

      BookingService.getUserBookings(userId).listen((bookings) {
        _userBookings = bookings;
        _separateBookings();
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Separate bookings into upcoming and past
  void _separateBookings() {
    final now = DateTime.now();
    _upcomingBookings = _userBookings
        .where((booking) =>
            booking.checkInDate.isAfter(now) &&
            (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed))
        .toList();

    _pastBookings = _userBookings
        .where((booking) =>
            booking.checkOutDate.isBefore(now) ||
            booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.completed)
        .toList();
  }

  // Create a new booking
  Future<String?> createBooking({
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
      _setLoading(true);
      _clearError();

      final bookingId = await BookingService.createBooking(
        userId: userId,
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        numberOfGuests: numberOfGuests,
        purpose: purpose,
      );

      return bookingId;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _clearError();

      await BookingService.cancelBooking(bookingId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      return await BookingService.getBookingById(bookingId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Set booking dates
  void setCheckInDate(DateTime date) {
    _selectedCheckInDate = date;

    // If check-out date is before or equal to check-in, clear it
    if (_selectedCheckOutDate != null &&
        _selectedCheckOutDate!.isBefore(date.add(const Duration(days: 1)))) {
      _selectedCheckOutDate = null;
    }

    notifyListeners();
  }

  void setCheckOutDate(DateTime date) {
    _selectedCheckOutDate = date;
    notifyListeners();
  }

  // Set number of guests
  void setNumberOfGuests(int guests) {
    _numberOfGuests = guests;
    notifyListeners();
  }

  // Calculate total price
  // Get number of days (office/campus booking context)
  int get numberOfDays {
    if (_selectedCheckInDate == null || _selectedCheckOutDate == null) {
      return 0;
    }
    return _selectedCheckOutDate!.difference(_selectedCheckInDate!).inDays;
  }

  // Check if dates are valid
  bool get areDatesValid {
    return _selectedCheckInDate != null &&
        _selectedCheckOutDate != null &&
        _selectedCheckOutDate!.isAfter(_selectedCheckInDate!);
  }

  // Clear booking data
  void clearBookingData() {
    _currentBooking = null;
    _selectedCheckInDate = null;
    _selectedCheckOutDate = null;
    _numberOfGuests = 1;
    notifyListeners();
  }

  // Get upcoming bookings count
  int get upcomingBookingsCount => _upcomingBookings.length;

  // Get past bookings count
  int get pastBookingsCount => _pastBookings.length;

  // Get bookings by status
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _userBookings.where((booking) => booking.status == status).toList();
  }



  // Get bookings by room ID
  Future<List<BookingModel>> getBookingsByRoomId(String roomId) async {
    try {
      return await BookingService.getBookingsByRoomId(roomId);
    } catch (e) {
      debugPrint('Error fetching bookings for room $roomId: $e');
      return [];
    }
  }

  // Refresh bookings
  Future<void> refreshBookings(String userId) async {
    loadUserBookings(userId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Validate booking dates
  String? validateDates() {
    if (_selectedCheckInDate == null) {
      return 'Please select check-in date';
    }
    if (_selectedCheckOutDate == null) {
      return 'Please select check-out date';
    }
    if (_selectedCheckInDate!.isBefore(DateTime.now())) {
      return 'Check-in date cannot be in the past';
    }
    if (_selectedCheckOutDate!
        .isBefore(_selectedCheckInDate!.add(const Duration(days: 1)))) {
      return 'Check-out date must be at least one day after check-in';
    }
    return null;
  }

  // Get minimum selectable date (tomorrow)
  DateTime get minSelectableDate => DateTime.now().add(const Duration(days: 1));

  // Get maximum selectable date (1 year from now)
  DateTime get maxSelectableDate =>
      DateTime.now().add(const Duration(days: 365));
}
