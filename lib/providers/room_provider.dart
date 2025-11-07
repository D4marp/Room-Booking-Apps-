import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];
  List<RoomModel> _filteredRooms = [];
  List<String> _cities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter properties
  String _searchQuery = '';
  String? _selectedCity;
  bool? _hasACFilter;
  double? _minPrice;
  double? _maxPrice;

  // Getters
  List<RoomModel> get rooms => _filteredRooms;
  List<RoomModel> get allRooms => _rooms;
  List<String> get cities => _cities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  bool? get hasACFilter => _hasACFilter;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  RoomProvider() {
    _loadInitialData();
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadRooms(),
      loadCities(),
    ]);
  }

  // Load all rooms
  Future<void> loadRooms() async {
    try {
      _setLoading(true);
      _clearError();

      RoomService.getAllRooms().listen((rooms) {
        _rooms = rooms;
        _applyFilters();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load cities
  Future<void> loadCities() async {
    try {
      _cities = await RoomService.getPopularCities();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Search rooms
  Future<void> searchRooms(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final searchResults = await RoomService.searchRooms(query);
      _filteredRooms = searchResults;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Filter rooms by city
  void filterByCity(String? city) {
    _selectedCity = city;
    _applyFilters();
  }

  // Filter rooms by AC
  void filterByAC(bool? hasAC) {
    _hasACFilter = hasAC;
    _applyFilters();
  }

  // Filter rooms by price range
  void filterByPriceRange(double? minPrice, double? maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    List<RoomModel> filtered = List.from(_rooms);

    // Apply city filter
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filtered = filtered
          .where(
              (room) => room.city.toLowerCase() == _selectedCity!.toLowerCase())
          .toList();
    }

    // Apply AC filter
    if (_hasACFilter != null) {
      filtered = filtered.where((room) => room.hasAC == _hasACFilter).toList();
    }

    // Apply price filter
    if (_minPrice != null) {
      filtered = filtered.where((room) => room.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      filtered = filtered.where((room) => room.price <= _maxPrice!).toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((room) =>
              room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              room.location
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              room.city.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    _filteredRooms = filtered;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCity = null;
    _hasACFilter = null;
    _minPrice = null;
    _maxPrice = null;
    _applyFilters();
  }

  // Get room by ID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      return await RoomService.getRoomById(roomId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Check room availability
  Future<bool> checkRoomAvailability(
      String roomId, DateTime checkIn, DateTime checkOut) async {
    try {
      return await RoomService.isRoomAvailable(roomId, checkIn, checkOut);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get rooms by city (for city-specific pages)
  Future<List<RoomModel>> getRoomsByCity(String city) async {
    try {
      _setLoading(true);
      _clearError();

      final rooms = <RoomModel>[];
      await for (final roomList in RoomService.getRoomsByCity(city)) {
        rooms.clear();
        rooms.addAll(roomList);
        break; // Get the first emission
      }
      return rooms;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadInitialData();
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

  // Get filtered room count
  int get filteredRoomCount => _filteredRooms.length;

  // Check if any filters are active
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCity != null ||
        _hasACFilter != null ||
        _minPrice != null ||
        _maxPrice != null;
  }

  // Get price range for slider
  Map<String, double> get priceRange {
    if (_rooms.isEmpty) return {'min': 0, 'max': 10000};

    final prices = _rooms.map((room) => room.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }
}
