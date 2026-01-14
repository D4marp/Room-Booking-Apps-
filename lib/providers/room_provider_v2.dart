import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class RoomProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
}
