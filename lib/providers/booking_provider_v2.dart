import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get booking by ID
  BookingModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch all bookings
  Future<void> fetchBookings({String? userId, String? roomId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = ApiConfig.bookingsEndpoint;
      if (userId != null || roomId != null) {
        final params = <String>[];
        if (userId != null) params.add('userId=$userId');
        if (roomId != null) params.add('roomId=$roomId');
        endpoint += '?${params.join('&')}';
      }

      final response = await ApiService().get(endpoint);
      
      if (response['data'] != null) {
        _bookings = (response['data'] as List)
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create booking
  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConfig.bookingsEndpoint,
        data: booking.toJson(),
      );

      if (response['data'] != null) {
        final newBooking = BookingModel.fromJson(response['data']);
        _bookings.add(newBooking);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Failed to create booking';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update booking
  Future<bool> updateBooking(String id, BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().put(
        '${ApiConfig.bookingsEndpoint}/$id',
        data: booking.toJson(),
      );

      if (response['data'] != null) {
        final updatedBooking = BookingModel.fromJson(response['data']);
        final index = _bookings.indexWhere((b) => b.id == id);
        if (index >= 0) {
          _bookings[index] = updatedBooking;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Failed to update booking';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete booking
  Future<bool> deleteBooking(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService().delete('${ApiConfig.bookingsEndpoint}/$id');
      
      _bookings.removeWhere((booking) => booking.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String id) {
    final booking = getBookingById(id);
    if (booking == null) return Future.value(false);
    return updateBooking(id, booking.copyWith(status: BookingStatus.cancelled));
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
