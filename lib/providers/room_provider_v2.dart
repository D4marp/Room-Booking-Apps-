import 'package:flutter/material.dart';
import 'dart:async';
import '../models/room_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class RoomProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _autoRefreshTimer;
  final StreamController<String> _eventController = StreamController<String>.broadcast();

  // Getters
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<String> get roomEvents => _eventController.stream;

  // Get room by ID
  RoomModel? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch all rooms
  Future<void> fetchRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConfig.roomsEndpoint);
      
      if (response['data'] != null) {
        _rooms = (response['data'] as List)
            .map((room) => RoomModel.fromJson(room))
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

  // Create room
  Future<bool> createRoom(RoomModel room) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConfig.roomsEndpoint,
        data: room.toJson(),
      );

      if (response['data'] != null) {
        final newRoom = RoomModel.fromJson(response['data']);
        _rooms.add(newRoom);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Failed to create room';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update room
  Future<bool> updateRoom(String id, RoomModel room) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().put(
        '${ApiConfig.roomsEndpoint}/$id',
        data: room.toJson(),
      );

      if (response['data'] != null) {
        final updatedRoom = RoomModel.fromJson(response['data']);
        final index = _rooms.indexWhere((r) => r.id == id);
        if (index >= 0) {
          _rooms[index] = updatedRoom;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Failed to update room';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete room
  Future<bool> deleteRoom(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService().delete('${ApiConfig.roomsEndpoint}/$id');
      
      _rooms.removeWhere((room) => room.id == id);
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

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Event-driven: Start listening to room changes
  void startListeningToRoomChanges({int refreshIntervalSeconds = 30}) {
    // Cancel existing timer if any
    _autoRefreshTimer?.cancel();
    
    // Set up periodic refresh
    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: refreshIntervalSeconds),
      (_) {
        _fetchRoomsForEvent();
      },
    );
  }

  // Event-driven: Stop listening
  void stopListeningToRoomChanges() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // Internal fetch for event-driven updates (doesn't show loading)
  Future<void> _fetchRoomsForEvent() async {
    try {
      final response = await ApiService().get(ApiConfig.roomsEndpoint);
      
      if (response['data'] != null) {
        final newRooms = (response['data'] as List)
            .map((room) => RoomModel.fromJson(room))
            .toList();
        
        // Check if rooms have changed
        if (_hasRoomsChanged(newRooms)) {
          _rooms = newRooms;
          _eventController.add('rooms_updated');
          notifyListeners();
        }
      }
    } catch (e) {
      _eventController.add('rooms_error: $e');
    }
  }

  // Check if room list has changed
  bool _hasRoomsChanged(List<RoomModel> newRooms) {
    if (_rooms.length != newRooms.length) return true;
    
    for (int i = 0; i < _rooms.length; i++) {
      if (_rooms[i].id != newRooms[i].id) return true;
    }
    return false;
  }

  // Trigger manual event
  void triggerRoomEvent(String eventType) {
    _eventController.add(eventType);
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _eventController.close();
    super.dispose();
  }
}
